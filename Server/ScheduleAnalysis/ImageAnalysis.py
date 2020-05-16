# -----------------------------------------------------------
# Computer vision process
#
# 2020 Mircea Gosman, Terrebonne, Canada
# email mirceagosman@gmail.com
# -----------------------------------------------------------
import operator
import re
import cv2 as cv
import numpy as np
import pytesseract
from pytesseract import Output
from Helpers.CustomMath import intersects, findMedian

class ImageAnalysis:
    # Initializer
    def __init__(self, fileName):
        self.fileName = fileName

    # Meta steps of the computer vision process 
    def initiateAnalysis(self):
        scheduleCrop, borderSize = self.cropScheduleFromImage(self.fileName)
        corners = self.extractCornersFromSchedule(scheduleCrop)
        gridCorners = self.filterGridCorners(corners, borderSize, scheduleCrop.shape[0])
        graphicalLines = self.extractLinesFromSchedule(scheduleCrop)
        connectedCorners = self.establishConnections(gridCorners, graphicalLines)
        gridCells = self.buildCells(connectedCorners)
        times, days = self.extractText(gridCells, scheduleCrop)
        self.formatTimes(times)
        dayTitles = self.formatDays(days)
        self.assignCourseTimeBounds(times, days)

        return days, dayTitles

    # Crop the image to its biggest polygon (likely to be the schedule)
    def cropScheduleFromImage(self, fileName):
        # Read the image file
        img = cv.imread(self.fileName)
        
        # Apply filters
        imgray = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
        edges = cv.Canny(imgray,50,150,apertureSize = 3)
        
        # Extract image contours
        contours, hierarchy = cv.findContours(edges, cv.RETR_TREE, cv.CHAIN_APPROX_NONE)
        
        # Sort contours by area size
        contours = sorted(contours, key=cv.contourArea, reverse=True) # seemingly same contours as after the crop

        # Set biggest contour as a shape containing the schedule
        polygon = contours[0]

        # Identify the shapes's extremities 
        topLeft, _ = min(enumerate([pt[0][0] + pt[0][1] for pt in polygon]), key =operator.itemgetter(1))
        bottomLeft, _ = min(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key =operator.itemgetter(1))
        topRight, _ = max(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key =operator.itemgetter(1))

        width = polygon[topRight][0][0] - polygon[topLeft][0][0]
        height = polygon[bottomLeft][0][1] - polygon[topLeft][0][1]

        # Crop the image to the schedule's shape
        cropImg = img[polygon[topLeft][0][1]:polygon[topLeft][0][1]+height, polygon[topLeft][0][0]:polygon[topLeft][0][0]+width]

        # Add a border to the cropped image (blue because its unlikely to be present in image)
        borderSize = 10

        return cv.copyMakeBorder(cropImg, borderSize, borderSize, borderSize, borderSize, cv.BORDER_CONSTANT,value=[255,0,0]), borderSize

    # Extract the corners from the schedule as coordinates (solution from documentation)
    def extractCornersFromSchedule(self, scheduleCrop):
        # Apply filters
        grayScale = cv.cvtColor(scheduleCrop, cv.COLOR_BGR2GRAY)
        edges = cv.Canny(grayScale,25,150,apertureSize = 3)
        gray = np.float32(edges)
        
        # Extract corners
        dst = cv.cornerHarris(gray,2,3,0.04)

        # Result is dilated for marking the corners, not important
        dst = cv.dilate(dst,None)

        ret, dst = cv.threshold(dst,0.01*dst.max(),255,0)
        dst = np.uint8(dst)

        # Find centroids
        ret, labels, stats, centroids = cv.connectedComponentsWithStats(dst)

        # Define the criteria to stop and refine the corners
        criteria = (cv.TERM_CRITERIA_EPS + cv.TERM_CRITERIA_MAX_ITER, 100, 0.001)

        # Return a list of corners i.e. [[x,y], [x,y], ...] where [x,y] is a corner
        return cv.cornerSubPix(gray,np.float32(centroids),(5,5),(-1,-1),criteria)

    # Extract line segments from the image as pairs of endpoint coordinates
    def extractLinesFromSchedule(self, scheduleCrop):
        # Apply filters
        gray = cv.cvtColor(scheduleCrop, cv.COLOR_BGR2GRAY)                     
        edges = cv.Canny(gray,25,150,apertureSize = 3)
        
        # Extract line segments
        glines = cv.HoughLinesP(edges,1,np.pi/180,1,1,0)
        
        # Filter out vertical lines
        graphLines = []

        for i in range(len(glines)):
            for x1,y1,x2,y2 in glines[i]:
                if y2 - y1 == 0: 
                    graphLines.append([x1,y1,x2,y2])

        # Return list of line segments in the image i.e. [[x1,y1,x2,y2], [x1,y1,x2,y2], ...]
        return graphLines
    
    # Format and filter corners into normalized columns
    def filterGridCorners(self, corners, borderSize, imgHeight):
        # Parameters
        baseThresholdY = 3
        baseThresholdX = 5
        minimumSubCorners = 3
        possibleConnectionThreshold = 4

        # Identify columns' bottom corners
        columnStartCorners = self.identifyColumns(baseThresholdY, corners, borderSize, imgHeight)
        
        # Build columns from their bottom corners
        unStructuredGridCorners = self.buildGrid(baseThresholdX, corners, columnStartCorners)

        # Return a clean version of unStructuredGridCorners (filtered errors & missing corners)
        return self.filterGrid(minimumSubCorners, possibleConnectionThreshold, unStructuredGridCorners)

    # Identify columns' bottom corners
    def identifyColumns(self, baseThresholdY, corners, borderSize, imgHeight):
        startCorners = []   # First draw of bottom conrners
        startCornersX = []  # X coordinate of bottom corners

        # Pick corners in the bottom-padding of the image
        for corner in corners:
            if corner[1] > imgHeight - borderSize - baseThresholdY:
                startCorners.append(corner)
                startCornersX.append(corner[0])

        # Sort the corners based on their position (left to right) 
        startCorners = [x for _,x in sorted(zip(startCornersX, startCorners))]
        startCornersX.sort()

        # Try to account for extra columns via median distance btw corners monitoring
        distances = []
        for i in range(len(startCornersX)):
            if i != len(startCornersX) - 1:
                distances.append(abs(startCornersX[i + 1] - startCornersX[i]))
        
        # Define an arbitrary ratio for the threshold
        medianThreshold = findMedian(distances)*4/5
        
        finalCorners = [] # Last draw of the bottom corners
        for i in range(len(startCorners)):
            if i != len(startCorners) - 1 and i != 0:
                rightDiff = startCorners[i + 1][0] -  startCorners[i][0]
                leftDiff = startCorners[i][0] - startCorners[i - 1][0]

                if leftDiff >= medianThreshold or rightDiff >= medianThreshold: # not universal but decently general & simple
                    finalCorners.append(startCorners[i])
            else:
                finalCorners.append(startCorners[i])

        # Return remaining list of columns starting corners
        return finalCorners

    # Build columns from their bottom corners
    def buildGrid(self, baseThresholdX, corners, columnStartCorners):
        unStructuredGridCorners = [] # Columns of corners from identified bottom corners
        
        # Add corners to columns
        for i in range(len(columnStartCorners)):
            unStructuredGridCorners.append([])
            for corner in corners:
                if corner[0] < columnStartCorners[i][0] + baseThresholdX and corner[0] > columnStartCorners[i][0] - baseThresholdX:
                    unStructuredGridCorners[i].append(corner)

        # Return list of columns containing vertically alined corners within thresholdX
        return unStructuredGridCorners

    # Remove unnecessary columns from columns' list
    def filterGrid(self, minimumSubCorners, possibleConnectionThreshold, unStructuredGridCorners):
        structuredGridCorners = [] # Filtered columns
        # longestColumnIndex = 0     
        cornersY = [unStructuredGridCorners[0][0][1]] # Default comparator for Y coordinate

        # Filter corners
        for i in range(len(unStructuredGridCorners)):
            columnLength = len(unStructuredGridCorners[i])

            # Keep only columns containing a minimum of points (filter out text & errors)
            if columnLength > minimumSubCorners:

                # Try to account for missing corners in some columns (but present in others)
                for j in range(len(unStructuredGridCorners[i])):
                    newLineCoordinate  = False
                    
                    # Normalize Y coordinates among columns
                    for yCoordinate in cornersY:
                        distanceFromKnownLine = abs(unStructuredGridCorners[i][j][1] - yCoordinate)
                        if (distanceFromKnownLine != 0 and
                            distanceFromKnownLine < possibleConnectionThreshold):
                                newLineCoordinate = True
                    if not newLineCoordinate:
                        cornersY.append(unStructuredGridCorners[i][j][1])

        # Sort & Remove duplicates
        cornersY = list(set(cornersY))
        cornersY.sort()

        # Fill the final corner grid
        for i in range(len(unStructuredGridCorners)):
            column = []
            for yCoordinate in cornersY:
                column.append([unStructuredGridCorners[i][0][0], yCoordinate])
            structuredGridCorners.append(column)

        # Return a list of columns containing corners with normalized Y coordinates
        return structuredGridCorners

    # Pair corners from 2 adjacent columns
    def establishConnections(self, gridCorners, graphLines):
        # Parameter
        possibleConnectionThreshold = 2
        
        connectedCorners = [] # Wrapper list
        for i in range(len(gridCorners)):
            if i != len(gridCorners) - 1:
                connectedCorners.append([]) # Add pair column
                
                for cornerA in gridCorners[i]:
                    for cornerB in gridCorners[i + 1]:
                        distanceAB = cornerB[0] - cornerA[0]
                        
                        # Link corners 2 by 2 based on the proximity of their Y coordinates 
                        if abs(cornerA[1] - cornerB[1]) < possibleConnectionThreshold:
                            connectionPoints = 0
                            
                            # Proceed to link only if corners are linked by sufficient horizontal line segments
                            for line in graphLines:
                                lowestCorner = cornerA
                                highestCorner = cornerB

                                if(cornerA[1] < cornerB[1]):
                                    lowestCorner = cornerB
                                    highestCorner = cornerA
                                
                                # Check for intersection of line segments with the corners' average position
                                intersection = intersects((cornerA[0]+cornerB[0])/2,line)

                                # Check for X coordinates boundaries
                                if (line[0] >= cornerA[0] and line[2] <= cornerB[0] and
                                    intersection >= highestCorner[1] - possibleConnectionThreshold and
                                    intersection <= lowestCorner[1] + possibleConnectionThreshold) :

                                        linelength = line[2] - line[0]
                                        
                                        # Account for single points
                                        if linelength == 0:
                                            connectionPoints += 1 
                                        else:
                                            connectionPoints += linelength
                            
                            # Horizontal line segments must cover at less half the distance btw corners
                            if connectionPoints >= distanceAB/2:
                                connectedCorners[len(connectedCorners) - 1].append([cornerA, cornerB])

        # Return a list of columns of paired corners
        return connectedCorners

    # Pair each connectedCorner with a connectedCorner from directly adjacent column
    def buildCells(self, connectedCorners):
        gridCells = []

        for i in range(len(connectedCorners)):
            gridCells.append([])
            for j in range(len(connectedCorners[i])):
                if j != len(connectedCorners[i]) - 1:
                    gridCells[i].append([connectedCorners[i][j], connectedCorners[i][j + 1]])

        # Return list of columns of cells (1 cell = 4 corners that form a rectangle)
        return gridCells

    # Run Tesseract on every cell
    def extractText(self, gridCells, scheduleCrop):
        days = []
        times = []

        for i in range(len(gridCells)):
            if i != 0: # First column is the times' column
                days.append([]) # Create columns

            for j in range(len(gridCells[i])):
                # Crop Image
                cellImg = scheduleCrop[int(gridCells[i][j][0][0][1]):int(gridCells[i][j][1][1][1]), int(gridCells[i][j][0][0][0]):int(gridCells[i][j][1][1][0])]

                # Check if image is empty
                if cellImg.data:
                    # Add white border
                    cellImg = cv.copyMakeBorder(cellImg,10,10,10,10,cv.BORDER_CONSTANT,value=[255,255,255])
                    # Upscaling & grayscaling
                    cellImg = cv.cvtColor(cellImg, cv.COLOR_BGR2GRAY)
                    cellImg =  cv.resize(cellImg,None,fx=2, fy=2)
                    # Run Tesseract
                    imageData= pytesseract.image_to_data(cellImg, lang = 'fra',output_type=Output.DICT, config=r'--oem 1')

                    if i == 0:
                        text = self.filterText(imageData)
                        if len(text) != 0:
                            # Create information cell
                            times.append([])
                            # Keep position data if there is text
                            times[len(times) - 1].append(gridCells[i][j])
                            # Add text data (as an array of lines)
                            times[len(times) - 1].append(text)
                    else:
                        # Add text data (as a continuous string containing line breaks)
                        text = '\n'.join(self.filterText(imageData))
                        if len(text) != 0: # Filter empty grid cells
                            # Create information cell
                            days[i - 1].append([])
                            # Keep position data  if there is text
                            days[i - 1][len(days[i - 1]) - 1].append(gridCells[i][j])
                            days[i - 1][len(days[i - 1]) - 1].append(text)

        return times, days

    # Filter tesseract output
    def filterText(self, imageData):
        text = []
        for k in range(len(imageData['level'])):
            if int(imageData['conf'][k]) != -1  and imageData['text'][k] != '': # remove low confidence and empty results
                text.append(imageData['text'][k])
        return text

    # Add references for user if errors in timestamps are detected
    def formatTimes(self, times):
        for timeCell in times:
            if len(timeCell[1]) < 2:
                timeCell[1].append('?') # Leave reference to be changed by user in app
            else:
                for i in range(len(timeCell[1])):
                    # keep only numeric caracters
                    timeCell[1][i] = re.sub('[^0-9]','', timeCell[1][i])

                    for j in range(len(timeCell[1][i])):
                        c = int(timeCell[1][i][j])

                        if len(timeCell[1][i]) > 4 or (j == 0 and  c > 2) or (j == 2 and c > 5):
                            timeCell[1][i] = timeCell[1][i] + '?' # Let user know he might want to change the field
                            break

        # Could technically try to build f(timeStampInMinutes) = yCoordinateOfTimeStamp and attempt error corrections but not doing so for simplicity (atm).

    def formatDays(self, days):
        prefixeTitles = ['lun', 'mar', 'mer', 'jeu', 'ven', 'sam', 'dim']
        dayTitles = []
        titleCount = 0

        for day in days:
            for title in prefixeTitles:
                if title in day[0][1].lower():
                    titleCount += 1
                    dayTitles.append(title)

        if titleCount >= len(days)/2:
            for day in days:
                del day[0]
        else:
            dayTitles = []

        return dayTitles

    def assignCourseTimeBounds(self, times, days):
        for day in days:
            for course in day:
                startTime = times[0][1][0]  # times|cell|text|line
                endTime = times[0][1][0]
                                    # course|posData|con|corn|y    times|cell|posData|con|corn|y
                minStartTimeDistance = abs(course[0][0][0][1] - times[0][0][0][0][1])
                minEndTimeDistance = abs(course[0][1][0][1] - times[0][0][0][0][1])

                for timeCell in times:
                    topDiff = abs(course[0][0][0][1] - timeCell[0][0][0][1])
                    botDiff = abs(course[0][1][0][1] - timeCell[0][1][0][1])

                    if topDiff < minStartTimeDistance:
                        minStartTimeDistance = topDiff
                        startTime = timeCell[1][0]
                    if botDiff < minEndTimeDistance:
                        minEndTimeDistance = botDiff
                        endTime = timeCell[1][1]


                course.append([startTime, endTime])
