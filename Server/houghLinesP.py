import cv2
import numpy as np
import matplotlib.pyplot as plt

def formatText(linesBoundingBoxes) :
    linesBoundingBoxes = linesBoundingBoxes[2:-2]

    listD1 = linesBoundingBoxes.split('], [')
    listD2 = []
    for i in range(len(listD1)):
        listD2.append(listD1[i].split(', '))

    for i in range(len(listD2)):
        for j in range(len(listD2[i])):
            listD2[i][j] = float(listD2[i][j])
            listD2[i][j] =int(listD2[i][j])

    print(listD2)
    return listD2

def parseImage(imageFileName, imageFileText, imageTextBounds):
    img = cv2.imread(imageFileName)
    gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray,50,150,apertureSize = 3)
    minLineLength = 1
    maxLineGap = 0

    lines = cv2.HoughLinesP(edges,1,np.pi/180,1,minLineLength,maxLineGap)
    # as per https://opencv-python-tutroals.readthedocs.io/en/latest/py_tutorials/py_imgproc/py_houghlines/py_houghlines.html
    # the function returns the line's endpoints, probably already x and y

    listD2 = formatText(imageTextBounds)

    for i in range(len(lines)):
        for x1,y1,x2,y2 in lines[i]:
            cv2.line(img,(x1,y1),(x2,y2),(0,255,0),1)

    for i in range(len(listD2)):
        cv2.rectangle(img,(listD2[i][0],listD2[i][1]),(listD2[i][2],listD2[i][3]), (0,0,255),2)

    # do not use GUI when running web server otherwise OS throws exception
    #plt.imshow(img)
    #plt.show()

    cv2.imwrite('result.jpg',img)
