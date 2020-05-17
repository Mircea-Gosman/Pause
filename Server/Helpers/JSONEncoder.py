# -----------------------------------------------------------
# JSON formating for schedule and schedule contained objects
#
# 2020 Mircea Gosman, Terrebonne, Canada
# email mirceagosman@gmail.com
# -----------------------------------------------------------
from json import JSONEncoder

from ScheduleAnalysis.Schedule import Schedule
from ScheduleAnalysis.Day import Day
from ScheduleAnalysis.Course import Course

class ScheduleEncoder(JSONEncoder):

   # Override default function
   def default(self, element):
       # Default initializer
       response = {'Element:' : None}

       # Verify type of the element and proceed to property mapping
       if isinstance(element, Schedule):
           response =  {
            'days' : element.days
            }
       elif isinstance(element, Day):
            response =  {
                'title' : element.title,
                'courses' : element.courses
            }
       elif isinstance(element, Course):
            response = {
                'startTime' : element.startTime,
                'endTime' : element.endTime,
                'text' : element.text
            }

       return response
