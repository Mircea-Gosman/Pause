import math

def findMedian(lineList, orientation):
    medianeList = []
    median = 0

    for i in range(len(lineList)):                   # error check if len = 0
        if orientation in 'y':
            medianeList.append((lineList[i].topLeft[1] + lineList[i].height)/2)
        else:
            medianeList.append((lineList[i].topLeft[0] + lineList[i].width)/2)

    medianeList.sort()
    medianPosition = int((len(medianeList) + 1)/2)

    if len(medianeList)%2 == 0:
        median = (math.floor(medianeList[medianPosition]) + math.ceil(medianeList[medianPosition]))/2
    else:
        median = medianeList[medianPosition]


    return median

def yIntersects(yCoordinate, gLine):
    denominator = gLine[2] - gLine[0]

    if denominator != 0:
        # Linear function
        slope = (gLine[3] - gLine[1])/denominator
        if slope != 0:
            b = gLine[1] - gLine[0]*slope
            x = abs((yCoordinate - b)/slope)
        else:
            # Constant function :: ignore result as it is infinite
            x = 0
    else :
         #Constant non-function
        x = gLine[2]

    return int(x)

def xIntersects(xCoordinate, gLine):
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

# Remove a lineList (l2) from an other (l1) [lists of non duplicates]
def stripList(l1, l2):
    result = []

    for line in l1:
        found = False
        for line2 in l2:
            if line.text == line2.text:
                found = True
                break

        if not found:
            result.append(line)

    return result

# Sort a list of lines based on coordinates of contained lines (x or y)
def sortLineList(lineList, orientation):
    subList = []

    if orientation in 'x':
        for i in range(len(lineList)):
            subList.append(lineList[i].topLeft[0])
    elif orientation in 'y':
        for i in range(len(lineList)):
            subList.append(lineList[i].topLeft[1])

    return [x for _, x in sorted(zip(subList, lineList))]
