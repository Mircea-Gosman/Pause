from LineTypes import LineType

class Line:
    def __init__(self, coordinates, lineText, corrector = None):
        self.coordinates = coordinates # integers; [minX, maxY, maxX, minY] == [left, bottom, right, top]
        self.text = lineText

        if not corrector is None:
            self.corrector = corrector
            self.type = self.verifyType()

    def verifyType(self):
        if self.verifyDay():
            return LineType.DAY
        elif self.verifyHour():
            return LineType.HOUR
        else:
            return None

    def verifyDay(self):
        isDay = False

        for word in self.text.split():
            if self.corrector.correct(word):
                isDay = True
                break

        return isDay

    def verifyHour(self):
        return len(self.text) < 7 and len(self.text) > 2 and (':' or ';' or '.') in self.text

        # TODO: implement stronger or different verification algorithm if needed
