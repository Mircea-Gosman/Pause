from ScheduleAnalysis.Day import Day
from ScheduleAnalysis.Course import Course
from ScheduleAnalysis.ImageAnalysis import ImageAnalysis

class Schedule:
    def __init__(self, fileName=None, days=None):
        if days is None:
            analyser = ImageAnalysis(fileName)
            days, dayTitles = analyser.initiateAnalysis()
            self.buildObjectsForJson(days, dayTitles)
        elif fileName is None:
            self.days = days

    def buildObjectsForJson(self, days, dayTitles):
        self.days = []

        for i in range(len(days)):
            courses = []
            title = self.setDayTitlePrefixes(i)

            if len(dayTitles) != 0 and dayTitles[i] != '':
                title = dayTitles[i]

            for course in days[i]:
                courses.append(Course(course[2][0], course[2][1], course[1]))

            self.days.append(Day(title, courses))

    def setDayTitlePrefixes(self, i):
        switcher={
                        0:'lun',
                        1:'mar',
                        2:'mer',
                        3:'jeu',
                        4:'ven',
                        5:'sam',
                        6:'dim'
                     }

        return switcher.get(i,"?") # default is set to be changed by user
