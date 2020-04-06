import numpy as np
import cv2 as cv
import operator

def findScheduleBounds(fileName):
    im = cv.imread(fileName)
    imgray = cv.cvtColor(im, cv.COLOR_BGR2GRAY)

    edges = cv.Canny(imgray,50,150,apertureSize = 3)
    contours, hierarchy = cv.findContours(edges, cv.RETR_TREE, cv.CHAIN_APPROX_NONE)

    contours = sorted(contours, key=cv.contourArea, reverse=True)
    polygon = contours[0]                                                   # FRAGILE: error check to make sure 0 is fine

    topLeft, _ = min(enumerate([pt[0][0] + pt[0][1] for pt in polygon]), key =operator.itemgetter(1))
    bottomLeft, _ = min(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key =operator.itemgetter(1))
    topRight, _ = max(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key =operator.itemgetter(1))

    width = polygon[topRight][0][0] - polygon[topLeft][0][0]
    height = polygon[bottomLeft][0][1] - polygon[topLeft][0][1]

    return polygon[topLeft][0], width, height

def cropImage(fileName, topLeft,  width, height, test):
    img = cv.imread(fileName)

    # Crop the image
    cropImg = img[topLeft[1]:topLeft[1]+height, topLeft[0]:topLeft[0]+width]

    # TESTING ONLY
    #cv.imwrite('res'+str(test)+'.jpg',cropImg)

    return cropImg

def houghLinesP(image):
    if len(image.shape) != 2:
        gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY)
    else:
        gray = image

    edges = cv.Canny(gray,50,150,apertureSize = 3)
    minLineLength = 1
    maxLineGap = 0

    glines = cv.HoughLinesP(edges,1,np.pi/180,1,minLineLength,maxLineGap)
    glines2 = []

    for i in range(len(glines)):
        for x1,y1,x2,y2 in glines[i]:
            cv.line(image,(x1,y1),(x2,y2),(0,255,0),1)
            glines2.append([x1,y1,x2,y2])

    #cv.imwrite('resultGraphical.jpg',image)

    return glines2 # (x1, y1, x2, y2) points a l'extremite des lignes


# Enable cv.imwrite line for testing if needed
def drawTestLines(image, gLines):
    for i in range(len(gLines)):
        cv.line(image,(gLines[i][0],gLines[i][1]),(gLines[i][2],gLines[i][3]),(255,0,0),1)

    #cv.imwrite('resultGraphical2.jpg',image)

def drawTesttPoints(img, list):

    for point in list:
        cv.circle(img, (int(point[0]),int(point[1])), 3,(0,0,255), -1)

    #cv.imwrite('resultGraphicalPoints.jpg',img)

def drawCourses(fileName, topLeft, width, height, daySortedObjectCourses):

    img = cropImage(fileName, topLeft,  width, height, 0)

    for day in daySortedObjectCourses:
        for course in day.courses:
             x2= course.topLeft[0] + course.width
             y2= course.topLeft[1] + course.height
             cv.rectangle(img,(course.topLeft[0],course.topLeft[1]),(x2,y2), (0,0,255),2)

    cv.imwrite('debug.jpg',img)

    img = cropImage(fileName, topLeft,  width, height, 0)

    for day in daySortedObjectCourses:
        for course in day.courses:
            for line in course.lineList:
                x2= line.topLeft[0] + line.width
                y2= line.topLeft[1] + line.height
                cv.rectangle(img,(line.topLeft[0],line.topLeft[1]),(x2,y2), (0,0,255),2)

    #cv.imwrite('debug2.jpg',img)

def drawPoints(fileName, topLeft, width, height, points):
    img = cropImage(fileName, topLeft,  width, height, 0)

    for i in range(len(points)):
        cv.circle(img, (int(points[i][0]),int(points[i][1])), 5,(238,255,0), -1)

    #cv.imwrite('debug3.jpg',img)
