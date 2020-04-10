import json
import pickle

from Database.Database import db_session
from Database.Models.Models import User, Day, Course
from Helpers.JSONEncoder import ScheduleEncoder

def auth(key):
    isNew =  False

    if User.query.filter_by(key=key).first() is None:
        user = User(key=key)
        db_session.add(user)
        db_session.commit()
        isNew = True

    return json.dumps({'isNew' : isNew})


def importSchedule(key, schedule):
    # User reference
    user = User.query.filter_by(key=key).first()

    # TODO: return http error instead of string
    if user is None:
        return "Error loading user in database."
    else:
        # Create Days
        for day in schedule.days:
            dbDay = Day(user = user)
            db_session.add(dbDay)

            # Create Courses
            for course in day.courses:
                dbCourse = Course(start = course.startTime, end = course.endTime,
                                   text = course.text, day = dbDay)
                db_session.add(dbCourse)

        db_session.commit()

        return ScheduleEncoder().encode(schedule)


def updateSchedule(clientUser):
    clientUser = json.loads(clientUser)
    hasUpdated = True

    user = User.query.filter_by(key=clientUser['key']).first()

    if user is None:
        hasUpdated = False
    else:
        # Remove existing schedule data from db
        days = Day.query.filter_by(userID=user.id).all()

        for day in days:
            courses = Course.query.filter_by(weekDay=day.id).all()
            for course in courses:
                db_session.delete(course)
            db_session.delete(day)


        # Add client data in db
        for day in clientUser['schedule']['days']:
            dbDay = Day(user = user)
            db_session.add(dbDay)

            # Create Courses
            for course in day['courses']:
                dbCourse = Course(start = course['startTime'], end = course['endTime'],
                                   text = course['text'], day = dbDay)
                db_session.add(dbCourse)

        db_session.commit()

    return json.dumps({'hasUpdated' : hasUpdated})


# TODO: Complete query functionality when the client side code supports queries
def queryStore(form):
    print('Query code not yet available.')
