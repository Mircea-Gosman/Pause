import cv2
import numpy as np
import matplotlib.pyplot as plt
from LineTypes import LineType

def extractGraphical(imageFileName):
    img = cv2.imread(imageFileName)
    gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray,50,150,apertureSize = 3)
    minLineLength = 1
    maxLineGap = 0

    return cv2.HoughLinesP(edges,1,np.pi/180,1,minLineLength,maxLineGap) # (x1, y1, x2, y2) points a l'extremite des lignes

    # as per https://opencv-python-tutroals.readthedocs.io/en/latest/py_tutorials/py_imgproc/py_houghlines/py_houghlines.html
    # the function returns the line's endpoints, probably already x and y

    # do not use GUI when running web server otherwise OS throws exception
    # plt.imshow(img)
    # plt.show()

def drawGraphicalLines(imageFileName, linesList):
    img = cv2.imread(imageFileName)

    for i in range(len(linesList)):
        for x1,y1,x2,y2 in linesList[i]:
            cv2.line(img,(x1,y1),(x2,y2),(0,255,0),1)

    cv2.imwrite('resultGraphical.jpg',img)

def drawGraphicalLinesObject(imageFileName, linesList):
    img = cv2.imread(imageFileName)

    for i in range(len(linesList)):
        cv2.line(img,(linesList[i].start[0],linesList[i].start[1]),(linesList[i].end[0],linesList[i].end[1]),(0,255,0),1)

    cv2.imwrite('resultGraphical.jpg',img)

def drawPoints(imageFileName, points):
    img = cv2.imread(imageFileName)
    for i in range(len(points)):
        cv2.circle(img, (int(points[i][0]),int(points[i][1])), 5,(238,255,0), -1)

    cv2.imwrite('resultGraphicalPoints.jpg',img)

def drawTextualLines(imageFileName, linesList):
    img = cv2.imread(imageFileName)

    for i in range(len(linesList)):
        if linesList[i].type == LineType.DAY:
           cv2.rectangle(img,(linesList[i].coordinates[0],linesList[i].coordinates[1]),(linesList[i].coordinates[2],linesList[i].coordinates[3]), (0,0,255),2)
        if linesList[i].type == LineType.HOUR:
           cv2.rectangle(img,(linesList[i].coordinates[0],linesList[i].coordinates[1]),(linesList[i].coordinates[2],linesList[i].coordinates[3]), (0,255,0),2)
        if linesList[i].type == LineType.CLASS:
           cv2.rectangle(img,(linesList[i].coordinates[0],linesList[i].coordinates[1]),(linesList[i].coordinates[2],linesList[i].coordinates[3]), (255,0,0),2)
        if linesList[i].type == LineType.JUNK:
           cv2.rectangle(img,(linesList[i].coordinates[0],linesList[i].coordinates[1]),(linesList[i].coordinates[2],linesList[i].coordinates[3]), (242,0,255),2)
        #cv2.rectangle(img,(linesList[i].coordinates[0],linesList[i].coordinates[1]),(linesList[i].coordinates[2],linesList[i].coordinates[3]), (0,0,255),2)

    cv2.imwrite('resultTextual.jpg',img)

def drawCourses(imageFileName, courses):
    img = cv2.imread(imageFileName)


    for i in range(len(courses)):
        for j in range(len(courses[i].courses)):
            cv2.rectangle(img, (courses[i].courses[j].bounds[0],courses[i].courses[j].bounds[1]),(courses[i].courses[j].bounds[2],courses[i].courses[j].bounds[3]), (0,255,0),1)

    cv2.imwrite('resultTextual2.jpg',img)

def drawMedianY(fileName, median):
    im = cv2.imread(fileName)
    height = np.size(im, 0)
    width = np.size(im, 1)
    cv2.line(im, (0, median), (width,median), (246, 255, 71), 4)
    cv2.imwrite(fileName,im)

def drawMedianX(fileName, median):
    im = cv2.imread(fileName)
    height = np.size(im, 0)
    width = np.size(im, 1)
    cv2.line(im, (median, 0), (median, height), (246, 255, 71), 4)
    cv2.imwrite(fileName,im)
