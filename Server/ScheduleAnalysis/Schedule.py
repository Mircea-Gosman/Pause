import numpy as np
import Helpers.TesseractHelpers as tsH
import Helpers.OpenCVHelpers as cvH
import Helpers.CustomMathHelpers as cmtH

from sklearn.cluster import DBSCAN, MeanShift, estimate_bandwidth
from SpellChecker.OCRCorrector import Corrector
from ScheduleAnalysis.Course import Course
from ScheduleAnalysis.Day import Day

class Schedule:
    def __init__(self, fileName, topLeft, width, height):
        self.fileName = fileName
        self.topLeft = topLeft
        self.width = width
        self.height = height
        self.textLines = self.extractTextLines(self.topLeft, self.width, self.height, 1)
        self.graphicalLines = self.extractGraphicalLines(self.topLeft, self.width, self.height, 1)
        self.testPoints = []
        self.days = self.initiateAnalysis()

    def extractTextLines(self, topLeft, width, height, test, config=None):
        scheduleImg = cvH.cropImage(self.fileName, topLeft, width, height, test)

        if config is None:
            return tsH.readScheduleTextLines(scheduleImg)
        else:
            return tsH.readScheduleTextLines(scheduleImg, config)

    def extractGraphicalLines(self, topLeft, width, height, test):
        self.scheduleImg = cvH.cropImage(self.fileName, topLeft, width, height, test)
        return cvH.houghLinesP(self.scheduleImg)

    def initiateAnalysis(self):
        # LineHours = analyseHours() grouping function for hours
        lowResLineHours = self.extractLowResLineHours()
        lowResLineHoursPosition = cmtH.findMedian(lowResLineHours, 'x')
        mediumResLineHours = self.extractMediumResLineHours(lowResLineHours, lowResLineHoursPosition)
        lineHoursRegion = self.formatLineHoursRegion(mediumResLineHours)
        # Applying tesseract to hours column for 'better' results ||| FRAGILE: result isnt improved, find a way to run Tes. on individual hour squares
        highResLineHours = cmtH.sortLineList(self.extractTextLines(lineHoursRegion[0], lineHoursRegion[1], lineHoursRegion[2], 2, '6'), 'y')
        nonHours = cmtH.stripList(self.textLines, highResLineHours) # simplify further operations

        # Days
        lowResLineDays = self.extractLowResLineDays(nonHours)
        lowResLineDaysPosition = cmtH.findMedian(lowResLineDays, 'y')
        mediumResLineDays = cmtH.sortLineList(self.extractMediumResLineDays(lowResLineDays, lowResLineDaysPosition), 'x') # here more postprocessing can be done (like what is done with hours, chosing not to for poor results of existing hours method)

        # Courses
        lineCourses = cmtH.stripList(nonHours, mediumResLineDays)
        daySortedLineCourses = self.assignCourseLinesToDay(lineCourses, mediumResLineDays)
        daySortedObjectCourses = self.clusterCourseLines(daySortedLineCourses)

        # Assign start and end time to courses
        self.assignTimeToObjectCourses(highResLineHours, daySortedObjectCourses)

        cvH.drawCourses(self.fileName, self.topLeft, self.width, self.height, daySortedObjectCourses)
        cvH.drawPoints(self.fileName, self.topLeft, self.width, self.height, self.testPoints)

        print(daySortedObjectCourses)
        for day in daySortedObjectCourses:
            for course in day.courses:
                print('----------- Course -----------')
                print(course.startTime)
                print(course.endTime)
                print('++++++')
                for line in course.lineList:
                    print(line.text)

        return daySortedObjectCourses

    def extractLowResLineHours(self):
        lowResLineHours = []

        for line in self.textLines:
            if len(line.text) < 7 and len(line.text) > 2 and (':' or ';' or '.') in line.text: # TODO: implement stronger or different verification algorithm if needed
                lowResLineHours.append(line)

        return lowResLineHours

    def extractMediumResLineHours(self, lrLines, lrLinesPosition):
        mediumResLineHours = []

        for line in lrLines:
            tolerance = line.width/2
            if lrLinesPosition > line.topLeft[0] - tolerance and lrLinesPosition < line.topLeft[0] + line.width + tolerance:
            #    and line.coordinates[1] > daysMedianY):                                        # TODO: Add this condition later if wanted
                mediumResLineHours.append(line)

        return mediumResLineHours

    def formatLineHoursRegion(self, mediumResLineHours):
        minX = mediumResLineHours[0].topLeft[0]
        maxX = mediumResLineHours[0].topLeft[0] + mediumResLineHours[0].width
        tolerance = int(mediumResLineHours[0].height/2)
        testPoints = []
        testLines = []

        for line in mediumResLineHours:
            for i in range(len(self.graphicalLines)):
                yCoordinate = line.topLeft[1]
                gLine = self.graphicalLines[i]

                while (yCoordinate <= line.topLeft[1] + line.height):

                    if yCoordinate >= gLine[1] and yCoordinate <= gLine[3]:
                        #testLines.append(gLine)
                        intersection = cmtH.yIntersects(yCoordinate, self.graphicalLines[i])


                        if intersection >= maxX and intersection <= maxX + line.height/2:
                            maxX = intersection

                        if intersection <= minX and intersection >= minX - line.height/2:
                            minX = intersection

                    yCoordinate += 1

        minX -= tolerance
        maxX += tolerance

        testPoints.append([maxX, 200])
        testPoints.append([minX, 200])
        cvH.drawTesttPoints(self.scheduleImg, testPoints)
        cvH.drawTestLines(self.scheduleImg, testLines)

        return [[self.topLeft[0] + minX, self.topLeft[1]], maxX - minX, self.height]


    def extractLowResLineDays(self, possibleLines):
        corrector = Corrector('French')
        lowResLineDays = []

        for line in possibleLines:
            if corrector.correct(line.text):
                lowResLineDays.append(line)

        return lowResLineDays

    def extractMediumResLineDays(self, lowResLineDays, lrLinesPosition):
      mediumResLineDays = []

      for line in lowResLineDays:
          tolerance = line.height
          if lrLinesPosition > (line.topLeft[1] - tolerance) and lrLinesPosition < (line.topLeft[1] + line.height + tolerance):
              mediumResLineDays.append(line)

      return mediumResLineDays

    def assignCourseLinesToDay(self, lineCourses, lineDays):
        dayFilteredLineCourses = [[] for i in range(len(lineDays))]

        for i in range(len(lineCourses)):
            minXDifference = abs(lineDays[0].topLeft[0] - lineCourses[i].topLeft[0])
            closestDay = 0

            # Get minimal X distance
            for j in range(len(lineDays)):
                xDifference = abs(lineDays[j].topLeft[0] - lineCourses[i].topLeft[0])

                if  xDifference < minXDifference:
                    closestDay = j
                    minXDifference = xDifference

            dayFilteredLineCourses[closestDay].append(lineCourses[i])

        return dayFilteredLineCourses

    def clusterCourseLines(self, dayFilteredLineCourses):
        dayFilteredCourses = []

        for i in range(len(dayFilteredLineCourses)):
            # Identify groups
            clusterLabels = self.retrieveClusterLabels(dayFilteredLineCourses[i])

            # Assign every line to a previously identified group
            blockFilteredCourses = [[] for i in range(len(set(clusterLabels)))]

            for j in range(len(dayFilteredLineCourses[i])):
                for k in range(len(blockFilteredCourses)):
                    if clusterLabels[j] == k:
                        blockFilteredCourses[k].append(dayFilteredLineCourses[i][j])
                        break

            # Assign every group of lines to a Course object
            objectCourses = []

            for j in range(len(blockFilteredCourses)):
                if len(blockFilteredCourses[j]) != 0:
                    objectCourses.append(Course(blockFilteredCourses[j]))

            # Trim course list bounds based on graphicalLines data
            self.trimCourses(objectCourses)

            # Update the Schedule object course list
            dayFilteredCourses.append(Day(objectCourses))     # TODO: Give access to day name in Day() constructor, requires some reformating of current function

        return dayFilteredCourses

    def retrieveClusterLabels(self, dayFilteredLineCourse):
        # Create list of Y-coordinates of lines in a day
        YList = []
        min = dayFilteredLineCourse[0].topLeft[1]
        max = dayFilteredLineCourse[0].topLeft[1]
        height = 0

        for i in range(len(dayFilteredLineCourse)):                     # error check if len = 0
            YList.append([dayFilteredLineCourse[i].topLeft[1]])
            height += dayFilteredLineCourse[i].height

            if min > dayFilteredLineCourse[i].topLeft[1]:
                min = dayFilteredLineCourse[i].topLeft[1]
            if max < dayFilteredLineCourse[i].topLeft[1]:
                max = dayFilteredLineCourse[i].topLeft[1]

        # Label each Y-coordinate to a group of Y-coordinates
        npYList = np.array(YList)
        bandwidth = estimate_bandwidth(npYList, quantile= 0.355, n_jobs= -1)  # FRAGILE: quantile number heavily impacts clustering result
                                                                             # 0.3X-0.5 seem to work well with 2-3 classes per day
        if bandwidth < 10 :                                                  # figure out best treshold
            bandwidth = 20                                                   # bandwidth = 20 seems to work well for single class days
                                                                             # maybe try Affinity propagation instead ?
                                                                             # ref Aff. prop. :https://scikit-learn.org/stable/modules/generated/sklearn.cluster.AffinityPropagation.html#sklearn.cluster.AffinityPropagation
                                                                             # Reference MeanShift: https://scikit-learn.org/stable/modules/generated/sklearn.cluster.MeanShift.html#sklearn.cluster.MeanShift.fit

        # MeanShift tentative
        #courseClustering = MeanShift(bandwidth=bandwidth).fit(npYList)

        # DBSCAN Tentative
        courseClustering = DBSCAN(eps=2*height/len(dayFilteredLineCourse), min_samples=3).fit(npYList)


        return courseClustering.labels_

    def trimCourses(self, objectCourses):
        for i in range(len(objectCourses)):
            # Correct Tesserract bounding boxe imprecisions (Y axis only)
            yCoordinates = self.trimCoursesText(objectCourses[i])

            # Find real starting and ending coordinates of courses  (Y axis only)
            yCoordinates.sort()
            foundUP = False
            foundLow = False

            for j in range(len(yCoordinates)):
                if j != 0:
                    if not foundUP or not foundLow:
                        if (yCoordinates[j - 1] < objectCourses[i].topLeft[1] and
                            yCoordinates[j] >=  objectCourses[i].topLeft[1] and not foundUP):
                          objectCourses[i].height += objectCourses[i].topLeft[1] - yCoordinates[j - 1]
                          objectCourses[i].topLeft[1] = yCoordinates[j - 1]
                          foundUP = True
                        if(yCoordinates[j - 1] <= objectCourses[i].topLeft[1] + objectCourses[i].height and
                            yCoordinates[j] >  objectCourses[i].topLeft[1] + objectCourses[i].height and not foundLow):
                          objectCourses[i].height = yCoordinates[j] - objectCourses[i].topLeft[1]
                          foundLow = True
                    else:
                        break

            #TESTING

            self.testPoints.append(objectCourses[i].topLeft)
            self.testPoints.append([objectCourses[i].topLeft[0]+objectCourses[i].width,objectCourses[i].topLeft[1]+objectCourses[i].height])

    def trimCoursesText(self, objectCourse):
        yCoordinates = []
        lineHeightFraction = 2

        for i in range(len(self.graphicalLines)):
            xCoordinate = objectCourse.topLeft[0]

            while(xCoordinate <= objectCourse.topLeft[0] + objectCourse.width):
                if xCoordinate >= self.graphicalLines[i][0] and xCoordinate <= self.graphicalLines[i][2]:
                    yCoordinate = cmtH.xIntersects(xCoordinate, self.graphicalLines[i])
                    yCoordinates.append(yCoordinate)
                    #self.testPoints.append([xCoordinate, yCoordinate])

                    # Adjust upper bound (of text)
                    if  (yCoordinate > (objectCourse.topLeft[1] - objectCourse.averageLineHeight/lineHeightFraction) and
                         yCoordinate < objectCourse.topLeft[1]):
                       objectCourse.height += objectCourse.topLeft[1] - yCoordinate
                       objectCourse.topLeft[1] = yCoordinate

                       #self.testPoints.append([xCoordinate, yCoordinate])

                    # Adjust lower bound (of text)
                    if (yCoordinate < (objectCourse.topLeft[1] + objectCourse.height + objectCourse.averageLineHeight/lineHeightFraction) and
                         yCoordinate > objectCourse.topLeft[1] + objectCourse.height):
                       objectCourse.height = yCoordinate - objectCourse.topLeft[1]

                xCoordinate += 1



        return yCoordinates

    def assignTimeToObjectCourses(self, highResLineHours, daySortedObjectCourses):
        for day in daySortedObjectCourses:
            for course in day.courses:
                topDifference = abs((course.topLeft[1]) - (highResLineHours[0].topLeft[1] + highResLineHours[0].height/2))
                botDifference = abs((course.topLeft[1] + course.height) - (highResLineHours[0].topLeft[1] + highResLineHours[0].height/2))
                startTime = highResLineHours[0]
                endTime = highResLineHours[0]

                for hour in highResLineHours:
                    currentTopDifference = abs((course.topLeft[1]) - (hour.topLeft[1] + hour.height/2))
                    currentBotDifference = abs((course.topLeft[1] + course.height) - (hour.topLeft[1] + hour.height/2))

                    if currentTopDifference <= topDifference:
                        topDifference = currentTopDifference
                        startTime = hour
                    if currentBotDifference <= botDifference:
                        botDifference = currentBotDifference
                        endTime = hour

                course.setStartTime(startTime.text)
                course.setEndTime(endTime.text)

# 22 270 27 874
