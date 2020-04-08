from json import JSONEncoder

from ScheduleAnalysis.Schedule import Schedule
from ScheduleAnalysis.Day import Day
from ScheduleAnalysis.Course import Course

class ScheduleEncoder(JSONEncoder):
   def default(self, element):
       response = {'Element:' : None}

       if isinstance(element, Schedule):
           response =  {
            'days' : element.days
            }
       elif isinstance(element, Day):
            response =  {
                'title' : 'unsupported for now',
                'courses' : element.courses
            }
       elif isinstance(element, Course):
            response = {
                'startTime' : element.startTime,
                'endTime' : element.endTime,
                'text' : element.text
            }

       return response
