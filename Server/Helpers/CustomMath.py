import math

def intersects(xCoordinate, gLine):
    denominator = gLine[2] - gLine[0]

    if denominator != 0:
        # Linear function
        slope = (gLine[3] - gLine[1])/denominator
        b = gLine[1] - gLine[0]*slope
        y = xCoordinate*slope + b
    else :
         #Constant non-function
        y = gLine[1]

    return int(y)

def findMedian(list):
    median = 0

    list.sort()
    medianPosition = int((len(list) + 1)/2)

    if len(list)%2 == 0:
        median = (math.floor(list[medianPosition]) + math.ceil(list[medianPosition]))/2
    else:
        median = list[medianPosition]


    return median
