class GraphicalLine:
    def __init__(self, line):
        self.start = [line[0][0], line[0][1]]
        self.end = [line[0][2], line[0][3]]

    def intersects(self, xCoordinate):
        denominator = self.end[1] - self.start[1]

        if denominator != 0:
            # Linear function
            slope = (self.end[0] - self.start[0])/denominator
            b = self.start[1] - self.start[0]*slope

            y = xCoordinate*slope + b
        else :
            # Constant function
            y = self.start[1]

        return int(y)

    def isLinear(self):
        return not(0 == (self.end[1] - self.start[1]))

    def generatePoints(self):
        points = []
        xCoordinate = self.start[0]

        while(xCoordinate <= self.end[0]):
            points.append([xCoordinate, self.intersects(xCoordinate)])

            xCoordinate += 1

        return points
