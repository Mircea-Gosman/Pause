class Hour:
    def __init__(self, clusterCenter, order):
        self.clusterCenter = clusterCenter
        self.order = order
        self.lineHours = []

    def getClusterCenter(self):
        return self.clusterCenter

    def getNumberofLineHours(self):
        return len(self.lineHours)

    def addLineHour(self, lineHour):
        if len(self.lineHours) < 2:
            self.lineHours.append(lineHour)
        #TODO: else:  error
