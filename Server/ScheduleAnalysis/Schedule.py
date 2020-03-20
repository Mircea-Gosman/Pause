import numpy as np
import cv2 as cv
import operator

from sklearn.cluster import DBSCAN, MeanShift, estimate_bandwidth

from ScheduleAnalysis.Course import Course # weird that root of project has to be used
from ScheduleAnalysis.Day import Day
from ScheduleAnalysis.Hour import Hour
from ScheduleAnalysis.PortableSchedule import PortableSchedule

from ImageLine import Line
from LineTypes import LineType
from ImageGraphicalLine import GraphicalLine


import OpenCVHelper

class Schedule:
    def __init__(self, top_left, top_right, bottom_right, bottom_left):
        self.top_left = top_left
        self.top_right = top_right
        self.bottom_left = bottom_left
        self.bottom_right = bottom_right

        self.testPoints = []

        self.calculateBounds()

    def calculateBounds(self):
        self.leftBound = self.top_left[0] if self.top_left[0] < self.bottom_left[0] else self.bottom_left[0]
        self.rightBound = self.top_right[0] if self.top_right[0] > self.bottom_right[0] else self.bottom_right[0]
        self.lowerBound = self.bottom_left[1] if self.bottom_left[1] > self.bottom_right[1] else self.bottom_right[1]
        self.upperBound = self.top_left[1] if self.top_left[1] < self.top_right[1] else self.top_right[1]

    def storeComponents(self, textualLinesList, graphicalLinesList):
        self.graphicalLines = self.storeGraphicalComponents(graphicalLinesList)
        courses = []
        lineHours = []
        lineDays = []

        for i in range(len(textualLinesList)):
            if textualLinesList[i].type == LineType.CLASS:
                courses.append(textualLinesList[i])
            if textualLinesList[i].type == LineType.HOUR:
                lineHours.append(textualLinesList[i])
            if textualLinesList[i].type == LineType.DAY:
                lineDays.append(textualLinesList[i])

        lineDays = self.sortDays(lineDays)

        hours, hoursClustering = self.postProcessHours(lineHours)
        self.days = self.groupCourses(courses, lineDays) # self only for drawing purposes

        # Store the data in an Object to be transfered to JSON later
        self.PortableSchedule = PortableSchedule(self.assignHoursToCourses(self.days, hours, hoursClustering))

    def storeGraphicalComponents(self, allGraphicalLines):
        graphicalLines = []

        # Filter lines within schedule bounds
        for i in range(len(allGraphicalLines)):
            for x1,y1,x2,y2 in allGraphicalLines[i]:
                if (x1 > self.leftBound and x1 < self.rightBound and
                    y1 > self.upperBound  and y2 < self.lowerBound):
                  graphicalLines.append(GraphicalLine(allGraphicalLines[i]))

        return graphicalLines

    # Update hours list with information Firebase missed [missing items, incorrect text]
    def postProcessHours(self, lineHours):
        textPoints = []

        # Approximate hours' region X-Axis bounds
        minX = lineHours[0].coordinates[0]
        maxX = lineHours[0].coordinates[2]

        # Filter graphical lines to the hours' region
        for i in range(len(self.graphicalLines)):
            if self.graphicalLines[i].start[0] > minX and self.graphicalLines[i].end[0] < maxX:
                # Convert line to points
                linePoints = self.graphicalLines[i].generatePoints()

                # Attempt to separate horizontal lines (schedule layout) from text
                for j in range(len(linePoints)):
                    if self.graphicalLines[i].isLinear():
                        textPoints.append([linePoints[j][1]]) # Y axis only

        # Place graphical text points into groups
        nptextPoints = np.array(textPoints)
        bandwidth = estimate_bandwidth(nptextPoints, quantile= 0.038, n_jobs= -1) # FRAGILE adjust quantile number
        hoursClustering = MeanShift(bandwidth=bandwidth).fit(nptextPoints)
        clusterCenters = hoursClustering.cluster_centers_

        # For illustration only:
        for y in clusterCenters:
            self.testPoints.append([minX, y])

        # DBSCAN untweaked Alternative
        #hoursClustering = DBSCAN(eps=3, min_samples=5).fit(textPoints)
        #self.testPoints  = hoursClustering.components_

        hours = []
        # Create hour objects
        for i in range(len(clusterCenters)):
            hours.append(Hour(clusterCenters[i], i))

        # Assign textual hours to an hours Object
        for lineHour in lineHours:
            clusterCenter = hoursClustering.predict([[(lineHour.coordinates[1] + lineHour.coordinates[3])/2]])

            for hour in hours:
                if hour.getClusterCenter() == clusterCenters[clusterCenter[0]]:
                    hour.addLineHour(lineHour)

        # Add a line with pseudo-text to clusters that have no lines
        for hour in hours:
            if hour.getNumberofLineHours() == 0:
                y = hour.getClusterCenter()
                defaultHeight = lineHour.coordinates[1] - lineHour.coordinates[3]
                hour.addLineHour(Line([minX, y, maxX, y - defaultHeight], '?'))

        return hours, hoursClustering

    def sortDays(self, lineDays):
        xCoordinates = []
        for i in range(len(lineDays)):
            xCoordinates.append(lineDays[i].coordinates[0])

        return [x for _, x in sorted(zip(xCoordinates, lineDays))]

    def groupCourses(self, courses, lineDays):
        dayFilteredLines = [[] for i in range(len(lineDays))]
        dayFilteredCourses = []

        # Identify each line to a day
        for i in range(len(courses)):
            minXDifference = abs(lineDays[0].coordinates[0] - courses[i].coordinates[0])
            closestDay = 0

            # Get minimal X distance
            for j in range(len(lineDays)):
                xDifference = abs(lineDays[j].coordinates[0] - courses[i].coordinates[0])

                if  xDifference < minXDifference:
                    closestDay = j
                    minXDifference = xDifference

            dayFilteredLines[closestDay].append(courses[i])

        # Group lines to form courses
        for i in range(len(dayFilteredLines)):
            # Create list of Y-coordinates of lines in a day
            YList = []
            min = dayFilteredLines[i][0].coordinates[1]
            max = dayFilteredLines[i][0].coordinates[1]

            for j in range(len(dayFilteredLines[i])):                     # error check if len = 0
                YList.append([dayFilteredLines[i][j].coordinates[1]])

                if min > dayFilteredLines[i][j].coordinates[1]:
                    min = dayFilteredLines[i][j].coordinates[1]
                if max < dayFilteredLines[i][j].coordinates[1]:
                    max = dayFilteredLines[i][j].coordinates[1]

            # Label each Y-coordinate to a group of Y-coordinates
            npYList = np.array(YList)
            bandwidth = estimate_bandwidth(npYList, quantile= 0.38, n_jobs= -1)  # FRAGILE: quantile number heavily impacts clustering result
                                                                                 # 0.38-0.5 seem to work well with 2-3 classes per day
            if bandwidth < 10 :                                                  # figure out best treshold
                bandwidth = 20                                                   # bandwidth = 20 seems to work well for single class days
                                                                                 # maybe try Affinity propagation instead
                                                                                 # ref Aff. prop. :https://scikit-learn.org/stable/modules/generated/sklearn.cluster.AffinityPropagation.html#sklearn.cluster.AffinityPropagation
                                                                                 # Reference MeanShift: https://scikit-learn.org/stable/modules/generated/sklearn.cluster.MeanShift.html#sklearn.cluster.MeanShift.fit

            courseClustering = MeanShift(bandwidth=bandwidth).fit(npYList)

            # Assign every line to a previously identified group
            blockFilteredCourses = [[] for i in range(len(set(courseClustering.labels_)))]

            for j in range(len(dayFilteredLines[i])):
                for k in range(len(blockFilteredCourses)):
                    if courseClustering.labels_[j] == k:
                        blockFilteredCourses[k].append(dayFilteredLines[i][j])
                        break

            # Assign every group of lines to a Course object
            academicCourses = []

            for j in range(len(blockFilteredCourses)):
                academicCourses.append(Course(blockFilteredCourses[j]))

            # Trim course list bounds based on graphicalLines data
            self.trimCourses(academicCourses)

            # Update the Schedule object course list
            dayFilteredCourses.append(Day(academicCourses))

        return dayFilteredCourses

    def trimCourses(self, academicCourses):
        lineHeightFraction = 2

        for i in range(len(academicCourses)):
            yCoordinates = []

            # Correct Firebase bounding boxe issues (Y axis only)
            for j in range(len(self.graphicalLines)):
                xCoordinate = academicCourses[i].bounds[0]

                while(xCoordinate <= academicCourses[i].bounds[2]):
                    if xCoordinate >= self.graphicalLines[j].start[0] and xCoordinate <= self.graphicalLines[j].end[0]:
                        yCoordinate = self.graphicalLines[j].intersects(xCoordinate)
                        yCoordinates.append(yCoordinate)
                        #self.testPoints.append([xCoordinate, yCoordinate])

                        # Adjust upper bound (of text)
                        if  (yCoordinate > (academicCourses[i].bounds[1] - academicCourses[i].averageLineHeight/lineHeightFraction) and
                             yCoordinate < academicCourses[i].bounds[1]):
                           academicCourses[i].bounds[1] = yCoordinate

                        # Adjust lower bound (of text)
                        elif (yCoordinate < (academicCourses[i].bounds[3] + academicCourses[i].averageLineHeight/lineHeightFraction) and
                             yCoordinate > academicCourses[i].bounds[3]):
                           academicCourses[i].bounds[3] = yCoordinate

                    xCoordinate += 1

            # Find real starting and ending coordinates of courses  (Y axis only)
            yCoordinates.sort()
            foundUP = False
            foundLow = False

            for j in range(len(yCoordinates)):
                if j != 0:
                    if not foundUP or not foundLow:
                        if (yCoordinates[j - 1] < academicCourses[i].bounds[1] and
                            yCoordinates[j] >=  academicCourses[i].bounds[1] and not foundUP):
                          academicCourses[i].bounds[1] = yCoordinates[j - 1]
                          foundUP = True
                        if(yCoordinates[j - 1] <= academicCourses[i].bounds[3] and
                            yCoordinates[j] >  academicCourses[i].bounds[3] and not foundLow):
                          academicCourses[i].bounds[3] = yCoordinates[j]
                          foundLow = True
                    else:
                        break

    def assignHoursToCourses(self, days, hours, hoursClustering):
        for day in days:
            for course in day.courses:
                topBoundCluster = hoursClustering.predict([[course.bounds[1]]])
                lowBoundCluster = hoursClustering.predict([[course.bounds[3]]])
                foundTop = False
                foundLow = False

                print('------------------')
                for hour in hours:
                    if not foundTop or not foundLow:
                        if hour.getClusterCenter() == hoursClustering.cluster_centers_[topBoundCluster[0]] and not foundTop:
                            course.setStartHour(hour)
                            foundTop = True

                            string = ''
                            for line in hour.lineHours:
                                string = string + line.text
                            print('Starts at: ' + string)

                        if hour.getClusterCenter() == hoursClustering.cluster_centers_[lowBoundCluster[0]] and not foundLow:
                            course.setEndHour(hour)
                            foundLow = True

                            string = ''
                            for line in hour.lineHours:
                                string = string + line.text
                            print('Ends at: ' + string)

        return days

    @staticmethod
    def findScheduleBounds(fileName):
        im = cv.imread(fileName)
        imgray = cv.cvtColor(im, cv.COLOR_BGR2GRAY)

        edges = cv.Canny(imgray,50,150,apertureSize = 3)
        contours, hierarchy = cv.findContours(edges, cv.RETR_TREE, cv.CHAIN_APPROX_NONE)

        contours = sorted(contours, key=cv.contourArea, reverse=True)
        polygon = contours[0]                                                   # FRAGILE: error check to make sure 0 is fine

        bottom_right, _ = max(enumerate([pt[0][0] + pt[0][1] for pt in polygon]), key =operator.itemgetter(1))
        top_left, _ = min(enumerate([pt[0][0] + pt[0][1] for pt in polygon]), key =operator.itemgetter(1))
        bottom_left, _ = min(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key =operator.itemgetter(1))
        top_right, _ = max(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key =operator.itemgetter(1))

        return Schedule(polygon[top_left][0], polygon[top_right][0],polygon[bottom_right][0], polygon[bottom_left][0])

        #cv.circle(im, (polygon[top_left][0][0],polygon[top_left][0][1]), 5,(238,255,0), -1)
        #cv.circle(im, (polygon[top_right][0][0],polygon[top_right][0][1]), 5,(238,255,0), -1)
        #cv.circle(im, (polygon[bottom_right][0][0],polygon[bottom_right][0][1]), 5,(238,255,0), -1)
        #cv.circle(im, (polygon[bottom_left][0][0],polygon[bottom_left][0][1]), 5,(238,255,0), -1)

        #cv.imwrite(fileName,im)
