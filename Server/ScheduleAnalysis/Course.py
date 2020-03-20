class Course:
    def __init__(self, lineList):
        self.lineList = lineList
        self.bounds = self.computeBounds(lineList)
        self.averageLineHeight = self.calculateAverageLineHeight(lineList)

    def computeBounds(self, lineList):
        leftBound = lineList[0].coordinates[0]
        upperBound = lineList[0].coordinates[1]
        rightBound = lineList[0].coordinates[2]
        lowerBound = lineList[0].coordinates[3]

        for i in range(len(lineList)):
            if lineList[i].coordinates[0] < leftBound:
                leftBound = lineList[i].coordinates[0]

            if lineList[i].coordinates[3] < upperBound:
                upperBound = lineList[i].coordinates[3]

            if lineList[i].coordinates[2] > rightBound:
                rightBound = lineList[i].coordinates[2]

            if lineList[i].coordinates[1] > lowerBound:
                lowerBound = lineList[i].coordinates[1]

        return [leftBound, upperBound, rightBound, lowerBound]

    def calculateAverageLineHeight(self, lineList):
        average = 0

        for line in lineList:
            average += (line.coordinates[1] - line.coordinates[3])

        return int(average/len(lineList))

    def setStartHour(self, hour):
        self.startHour = hour

    def setEndHour(self, hour):
        self.endHour = hour
