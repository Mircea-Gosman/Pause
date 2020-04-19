import cv2 as cv
import operator

average_text_height = 30
average_width = 30

img = cv.imread('crop.jpg')
imgray = cv.cvtColor(img, cv.COLOR_BGR2GRAY)

edges = cv.Canny(imgray,25,150,apertureSize = 3)
cv.imshow('img',edges)
cv.waitKey()

contours, hierarchy = cv.findContours(edges, cv.RETR_LIST, cv.CHAIN_APPROX_NONE)

# filter out text contours
filteredContours = []  # contains duplicates, random contours

for polygon in contours:
    topLeft, _ = min(enumerate([pt[0][0] + pt[0][1] for pt in polygon]), key =operator.itemgetter(1))
    bottomLeft, _ = min(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key =operator.itemgetter(1))
    topRight, _ = max(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key =operator.itemgetter(1))

    height = polygon[bottomLeft][0][1] - polygon[topLeft][0][1]
    width = polygon[topRight][0][0] - polygon[topLeft][0][0]

    if height > average_text_height and width > average_width: # maybe do : if height is closer to average polygon height than closer to average line height.
    #    filteredContours.append(polygon)
        approx = cv.approxPolyDP(polygon, 0.1*cv.arcLength(polygon, True), True) # 0.1 can be different
        if len(approx) == 4:
            filteredContours.append(polygon)

end = sorted(filteredContours, key=cv.contourArea, reverse=False)

for i in range(len(end)):
    cv.drawContours(img, [end[i]], -1, (0,255,0), 3)

    cv.imshow('img',img)
    cv.waitKey()
