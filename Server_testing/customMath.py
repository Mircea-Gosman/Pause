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
