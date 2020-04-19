import cv2 as cv
import numpy as np
from customMath import intersects
import pytesseract
from pytesseract import Output

img = cv.imread('kevinCropSch.jpg')
gray = cv.cvtColor(img,cv.COLOR_BGR2GRAY)
edges = cv.Canny(gray,25,150,apertureSize = 3)

gray = np.float32(edges)
dst = cv.cornerHarris(gray,2,3,0.04)

#result is dilated for marking the corners, not important
dst = cv.dilate(dst,None)

ret, dst = cv.threshold(dst,0.01*dst.max(),255,0)
dst = np.uint8(dst)

#find centroids
ret, labels, stats, centroids = cv.connectedComponentsWithStats(dst)

#define the criteria to stop and refine the corners
criteria = (cv.TERM_CRITERIA_EPS + cv.TERM_CRITERIA_MAX_ITER, 100, 0.001)
corners = cv.cornerSubPix(gray,np.float32(centroids),(5,5),(-1,-1),criteria)

baseCorners = []
gridCorners = []
structuredGridCorners = []

# Parameters
baseThresholdY = 3
baseThresholdX = 5
minimumSubCorners = 3
possibleConnectionThreshold = 2


tempCorners = []
tempX = []
for corner in corners:
    if corner[1] > img.shape[0] - 10 - baseThresholdY: # 10 is added margin @ crop
        tempCorners.append(corner)
        tempX.append(corner[0])

# Discovered sorting is necessary after testing
temp = [x for _,x in sorted(zip(tempX,tempCorners))]    # using python list sort bc sorting experience is low
for corner in temp:
    baseCorners.append(corner)
    structuredGridCorners.append([])

for corner in corners:
    for i in range(len(baseCorners)):
        if corner[0] < baseCorners[i][0] + baseThresholdX and corner[0] > baseCorners[i][0] - baseThresholdX:
            gridCorners.append(corner)
            structuredGridCorners[i].append(corner)

filteredStructuredGridCorners = []
longestColumnIndex = 0
cornersY = [structuredGridCorners[0][0][1]]
for i in range(len(structuredGridCorners)):
    columnLength = len(structuredGridCorners[i])
    if columnLength > minimumSubCorners:
        for j in range(len(structuredGridCorners[i])):
            newLineCoordinate  = False
            for yCoordinate in cornersY:
                distanceFromKnownLine = abs(structuredGridCorners[i][j][1] - yCoordinate)
                if (distanceFromKnownLine != 0 and
                    distanceFromKnownLine < 2*possibleConnectionThreshold):
                        newLineCoordinate = True
            if not newLineCoordinate:
                cornersY.append(structuredGridCorners[i][j][1])

# Sort & Remove duplicates
cornersY = list(set(cornersY))
cornersY.sort()

# Try to account for missing corners
for i in range(len(structuredGridCorners)):
    column = []
    for yCoordinate in cornersY:
        column.append([structuredGridCorners[i][0][0], yCoordinate])
    filteredStructuredGridCorners.append(column)

# Show corners for testing
#for column in filteredStructuredGridCorners:
#    for corner in column:
#        cv.circle(img, (corner[0], corner[1]), 1, (0,0,255), 2)

#cv.imshow('img',img)
#cv.waitKey()
#        print(corner[1])


glines = cv.HoughLinesP(edges,1,np.pi/180,1,1,0)
graphLines = []
for i in range(len(glines)):
    for x1,y1,x2,y2 in glines[i]:
        if y2 - y1 == 0: # filter those without height
            graphLines.append([x1,y1,x2,y2])
            # cv.line(img,(x1,y1),(x2,y2),(0,255,0),1)

connectedCorners = []
for i in range(len(filteredStructuredGridCorners)):
    connectedCorners.append([])
    if i != len(filteredStructuredGridCorners) - 1:
        for cornerA in filteredStructuredGridCorners[i]:
            for cornerB in filteredStructuredGridCorners[i + 1]:
                distanceAB = cornerB[0] - cornerA[0]

                if abs(cornerA[1] - cornerB[1]) < possibleConnectionThreshold:
                    connectionPoints = 0

                    for line in graphLines:
                        lowestCorner = cornerA
                        highestCorner = cornerB

                        if(cornerA[1] < cornerB[1]):
                            lowestCorner = cornerB
                            highestCorner = cornerA

                        intersection = intersects((cornerA[0]+cornerB[0])/2,line)
                        if (line[0] >= cornerA[0] and line[2] <= cornerB[0] and
                            intersection >= highestCorner[1] - possibleConnectionThreshold and
                            intersection <= lowestCorner[1] + possibleConnectionThreshold) :

                                linelength = line[2] - line[0]
                                if linelength == 0:
                                    connectionPoints += 1 # single point line
                                else:
                                    connectionPoints += linelength

                    if connectionPoints >= distanceAB/2:
                        connectedCorners[i].append([cornerA, cornerB])

boxes = []
for column in connectedCorners:
    for i in range(len(column)):
        if i != len(column) - 1:
            boxes.append([column[i], column[i + 1]])

text = []
for boxe in boxes:
    cropImg = img[int(boxe[0][0][1]):int(boxe[1][1][1]), int(boxe[0][0][0]):int(boxe[1][1][0])]

    if cropImg.data:
        # Add white border
        cropImg = cv.copyMakeBorder(cropImg,10,10,10,10,cv.BORDER_CONSTANT,value=[255,255,255])
        # Testing filters
        cropImg = cv.blur(cropImg,(5,5))

        imageData= pytesseract.image_to_data(cropImg, lang = 'fra',output_type=Output.DICT, config=r'--oem 1')


        print('-----------')
        for i in range(len(imageData['level'])):
            if int(imageData['conf'][i]) != -1:
                text.append(imageData['text'][i])
                print(imageData['text'][i])

        #cv.imshow('img',cropImg)
        #cv.waitKey()

    #cv.line(img,(boxe[0][0][0],boxe[0][0][1]),(boxe[0][1][0],boxe[0][1][1]),(255,0,0),1)
    #cv.line(img,(boxe[1][0][0],boxe[1][0][1]),(boxe[1][1][0],boxe[1][1][1]),(255,0,0),1)
    #cv.line(img,(boxe[1][0][0],boxe[1][0][1]),(boxe[1][1][0],boxe[1][1][1]),(255,0,0),1)
    cv.rectangle(img,(boxe[0][0][0],boxe[0][0][1]),(boxe[1][1][0],boxe[1][1][1]),(255,0,0),1)

    #cv.imshow('img',img)
    #cv.waitKey()


cv.imshow('img',img)
cv.waitKey()

# Proceed-ed as follows:

# Apply cornerHarris
# remove text segments
# apply houghlinesP
# create connections between corners if there is houghLine of minimum half corner to corner distance in-between
# create boxes if above step doesnt do it
# on each box run tesseract
