from ImageLine import Line
import OpenCVHelper
import math
from SpellChecker.OCRCorrector import Corrector
from LineTypes import LineType
from ScheduleAnalysis.Schedule import Schedule

class ImageInfo:
  def __init__(self, coordinates, linesTextList, fileName):
     self.corrector = Corrector('French')
     self.textualLines =  self.groupTextLines(self.formatCoordinates(coordinates), self.formatLinesText(linesTextList))
     self.graphicalLines = OpenCVHelper.extractGraphical(fileName)
     self.fileName = fileName
     self.schedule = self.identifyScheduleComponents()

     OpenCVHelper.drawPoints(fileName, self.schedule.testPoints)
     #OpenCVHelper.drawGraphicalLinesObject(fileName, self.schedule.graphicalLinesTest)
     OpenCVHelper.drawGraphicalLines(fileName, self.graphicalLines)
     OpenCVHelper.drawCourses(fileName, self.schedule.days)
     OpenCVHelper.drawTextualLines(fileName, self.textualLines)

  def formatCoordinates(self, linesBoundingBoxes) :
    linesBoundingBoxes = linesBoundingBoxes[2:-2]

    listD1 = linesBoundingBoxes.split('], [')
    listD2 = []

    for i in range(len(listD1)):
        listD2.append(listD1[i].split(', '))

    for i in range(len(listD2)):
        for j in range(len(listD2[i])):
            listD2[i][j] = float(listD2[i][j])
            listD2[i][j] = int(listD2[i][j])

    return listD2

  def formatLinesText(self, imageFileText):
    imageFileText = imageFileText.replace('[', '')
    imageFileText = imageFileText.replace(']', '')

    linesTextList = imageFileText.split('&@^, ')
    print(linesTextList)
    print('-------------------')
    return linesTextList

  def groupTextLines(self, coordinatesList, textList):
     lines = []
     for i in range(len(coordinatesList)):
         lines.append(Line(coordinatesList[i], textList[i], self.corrector))
     return lines

  def identifyScheduleComponents(self):
      daysMedianY = self.findMedian(LineType.DAY, 'y')
      hoursMedianX = self.findMedian(LineType.HOUR, 'x')
      schedule = Schedule.findScheduleBounds(self.fileName)

      for i in range(len(self.textualLines)):
          line = self.textualLines[i]

          if self.computeBounds(line, schedule):
              line.type = LineType.CLASS
              self.identifyDay(line, daysMedianY)
              self.identifyHour(line, hoursMedianX, daysMedianY)

      schedule.storeComponents(self.textualLines, self.graphicalLines)

      return schedule

  def computeBounds(self, line, schedule):
      isSchedule = True

      if not (line.coordinates[1] > schedule.upperBound and line.coordinates[3] < schedule.lowerBound and
            line.coordinates[0] > schedule.leftBound and line.coordinates[2] < schedule.rightBound):
          line.type = LineType.JUNK
          isSchedule = False

      return isSchedule

  def identifyDay(self, line, daysMedianY):
      tolerance = (line.coordinates[1] - line.coordinates[3])/2

      if daysMedianY > (line.coordinates[3]-tolerance) and daysMedianY < (line.coordinates[1]+tolerance):
          line.type = LineType.DAY

  def identifyHour(self, line, hoursMedianX, daysMedianY):
      if (hoursMedianX > line.coordinates[0] and hoursMedianX < line.coordinates[2]
          and line.coordinates[1] > daysMedianY):
        line.type = LineType.HOUR

  def findMedian(self, type, orientation):
      medianeList = []
      median = 0

      for i in range(len(self.textualLines)):                   # error check if len = 0
          line = self.textualLines[i]
          if line.type == type:
              if orientation in 'y':
                  medianeList.append((line.coordinates[1] + line.coordinates[3])/2)
              else:
                  medianeList.append((line.coordinates[0] + line.coordinates[2])/2)

      medianeList.sort()
      medianPosition = int((len(medianeList) + 1)/2)

      if len(medianeList)%2 == 0:
          median = (math.floor(medianeList[medianPosition]) + math.ceil(medianeList[medianPosition]))/2
      else:
          median = medianeList[medianPosition]


      return median




#(x1,y1),(x2,y2)


# group class lines togheter
# make sure textual days didnt leave out any graphical days
# make sure textual hours didnt leave out any graphical hours
