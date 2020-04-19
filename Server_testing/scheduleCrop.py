import cv2 as cv
import operator

img = cv.imread('kevinSch.png')
imgray = cv.cvtColor(img, cv.COLOR_BGR2GRAY)

edges = cv.Canny(imgray,50,150,apertureSize = 3)
contours, hierarchy = cv.findContours(edges, cv.RETR_TREE, cv.CHAIN_APPROX_NONE)

contours = sorted(contours, key=cv.contourArea, reverse=True) # seemingly same contours as after the crop

polygon = contours[0]

topLeft, _ = min(enumerate([pt[0][0] + pt[0][1] for pt in polygon]), key =operator.itemgetter(1))
bottomLeft, _ = min(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key =operator.itemgetter(1))
topRight, _ = max(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key =operator.itemgetter(1))

width = polygon[topRight][0][0] - polygon[topLeft][0][0]
height = polygon[bottomLeft][0][1] - polygon[topLeft][0][1]

# Crop the image
cropImg = img[polygon[topLeft][0][1]:polygon[topLeft][0][1]+height, polygon[topLeft][0][0]:polygon[topLeft][0][0]+width]
cropImg = cv.copyMakeBorder(cropImg,10,10,10,10,cv.BORDER_CONSTANT,value=[255,0,0]) # this border should not be white otherwise border corners may not react so well

cv.imwrite('kevinCropSch.jpg',cropImg)
