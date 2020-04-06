import json

from Database.Database import db_session
from Database.Models.Models import User, Day, Course

def auth(key):
    isNew =  False

    if User.query.filter_by(key=key).first() is None:
        user = User(key=key)
        db_session.add(user)
        db_session.commit()
        isNew = True

    return json.dumps({'isNew' : isNew})


def importSchedule(key, days):
    # User reference
    user = User.query.filter_by(key=key).first()

    # TODO: return http error instead of string
    if user is None:
        return "Error loading user in database."
    else:
        # Create Days
        for day in days:
            dbDay = Day(user = user)
            db_session.add(dbDay)

            # Create Courses
            for course in day.courses:
                dbCourse = Course(start = course.startTime, end = course.endTime,
                                   text = course.text, day = dbDay)
                db_session.add(dbCourse)

        db_session.commit()

        return 'Schedule succesfully imported in database.'


# TODO: Complete update functionality when the client side code supports updates
def updateStore(form):
    print('Update code not yet available.')


# TODO: Complete query functionality when the client side code supports queries
def queryStore(form):
    print('Query code not yet available.')
