class Course:
    def __init__(self, lineList):
        self.lineList = lineList

        self.computeBounds(lineList)

    def computeBounds(self, lineList):
        leftBound = lineList[0].topLeft[0]
        upperBound = lineList[0].topLeft[1]
        rightBound = lineList[0].topLeft[0] + lineList[0].width
        lowerBound = lineList[0].topLeft[1] + lineList[0].height
        totalLineHeight = 0

        for i in range(len(lineList)):
            if lineList[i].topLeft[0] < leftBound:
                leftBound = lineList[i].topLeft[0]

            if lineList[i].topLeft[1] < upperBound:
                upperBound = lineList[i].topLeft[1]

            if lineList[i].topLeft[0] + lineList[i].width > rightBound:
                rightBound = lineList[i].topLeft[0] + lineList[i].width

            if lineList[i].topLeft[1] + lineList[i].height > lowerBound:
                lowerBound = lineList[i].topLeft[1] + lineList[i].height

            totalLineHeight += lineList[i].height



        self.topLeft = [leftBound, upperBound]
        self.width = rightBound - leftBound
        self.height = lowerBound - upperBound
        self.averageLineHeight = int(totalLineHeight/len(lineList))

    def setStartTime(self, time):
        self.startTime = time

    def setEndTime(self, time):
        self.endTime = time
