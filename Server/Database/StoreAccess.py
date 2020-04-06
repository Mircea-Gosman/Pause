from Database.Database import db_session
from Database.Models.Models import User, Day, Course

def createUser(days):
    # Create User
    user = User()
    db_session.add(user)
    #db_session.commit()

    # Create Days
    for day in days:
        dbDay = Day(user = user)
        db_session.add(dbDay)
        #db_session.commit()

        # Create Courses
        for course in day.courses:
            dbCourse = Course(start = course.startTime, end = course.endTime,
                               text = course.text, day = dbDay)
            db_session.add(dbCourse)

    db_session.commit()


# TODO: Complete update functionality when the client side code supports updates
def updateStore(form):
    print('Update code not yet available.')


# TODO: Complete query functionality when the client side code supports queries
def queryStore(form):
    print('Query code not yet available.')
