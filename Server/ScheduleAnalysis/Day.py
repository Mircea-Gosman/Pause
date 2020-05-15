# -----------------------------------------------------------
# Day object for JSON to be sent to client
#
# 2020 Mircea Gosman, Terrebonne, Canada
# email mirceagosman@gmail.com
# -----------------------------------------------------------

class Day:
    # Initializer
    def __init__(self, title, courses):
        self.title = title          # String
        self.courses = courses      # Array of Course instances 
