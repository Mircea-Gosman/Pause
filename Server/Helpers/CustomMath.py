# -----------------------------------------------------------
# Math helper functions
#
# 2020 Mircea Gosman, Terrebonne, Canada
# email mirceagosman@gmail.com
# -----------------------------------------------------------

import math

# Compute linear intersections
def intersects(xCoordinate, gLine):
    # Calculate denominator
    denominator = gLine[2] - gLine[0]

    # Assure denominator is not 0
    if denominator != 0:
        # Compute linear function
        slope = (gLine[3] - gLine[1])/denominator
        b = gLine[1] - gLine[0]*slope
        y = xCoordinate*slope + b
    else :
        # Behave like a constant function
        y = gLine[1]

    # Return linear function result
    return int(y)

# Compute median value of the elements in a list
def findMedian(list):
    # Default initializer
    median = 0

    # Sort the list
    list.sort()

    # Calculate the median's position in the list
    medianPosition = int((len(list) + 1)/2)

    # Calculate median
    if len(list)%2 == 0:
        median = (math.floor(list[medianPosition]) + math.ceil(list[medianPosition]))/2
    else:
        median = list[medianPosition]

    # Return the median value of the list's elements
    return median
