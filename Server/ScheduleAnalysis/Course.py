# -----------------------------------------------------------
# Course object for JSON to be sent to client
#
# 2020 Mircea Gosman, Terrebonne, Canada
# email mirceagosman@gmail.com
# -----------------------------------------------------------

class Course:
    # Initializer
    def __init__(self, startTime, endTime, text):
        self.startTime = startTime  # String
        self.endTime = endTime      # String
        self.text = text            # String
