import json

from Database.Database import db_session
from Database.Models.Models import User, Day, Course
from Helpers.JSONEncoder import ScheduleEncoder

from ScheduleAnalysis.Day import Day as cDay
from ScheduleAnalysis.Course import Course as cCourse
from ScheduleAnalysis.Schedule import Schedule

def auth(key, friendList):
    isNew =  False

    if User.query.filter_by(key=key).first() is None:
        user = User(key=key)
        db_session.add(user)
        db_session.commit()
        isNew = True

        # Create user friendList
        friendKeyList = json.loads(friendList)

        for friendKey in friendKeyList:
            # Add friend only if he is in database
            if not (User.query.filter_by(key=friendKey).first() is None):
                establishFriendConnection(key, friendKey)

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
            dbDay = Day(title = day.title, user = user)
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

def establishFriendConnection(key1, key2):
    # Check for existing connection
    user1 = User.query.filter_by(key=key1).first()
    user2 = User.query.filter_by(key=key2).first()

    connection1Exists = False
    connection2Exists = False

    for friend in user1.friends:
        if friend.id ==  user2.id:
            connection1Exists = True
            break

    for friend in user2.friends:
        if friend.id ==  user1.id:
            connection2Exists = True
            break

    # Add a connection
    if not connection1Exists:
        user1.friends.append(user2)
        db_session.commit()
    if not connection2Exists:
        user2.friends.append(user1)
        db_session.commit()

def notifyFriendsUpdate(key, friendListLength):
    clientFriends = []
    user = User.query.filter_by(key=key).first()

    if not (user is None):
        if len(user.friends) != friendListLength:
            for friend in user.friends:
                clientFriends.append({'key' : friend.key})

    return json.dumps({'friendList' : clientFriends})


# TODO: Migrate project to heroku and setup webhooks to Facebook to receive live FB friend list updates.
# https://developers.facebook.com/docs/graph-api/webhooks/getting-started
def updateFriendList():
    print('Friend list live updates not yet available.')

def queryStore(key):
    user = User.query.filter_by(key=key).first()

    # TODO: return http error instead of string
    if user is None:
        return "Error loading user in database."
    else:
        dbDays = Day.query.filter_by(userID=user.id).all()

        days = []
        for day in dbDays:
            dbCourses = Course.query.filter_by(weekDay=day.id).all()

            courses = []
            for course in dbCourses:
                courses.append(cCourse(course.start, course.end, course.text))

            days.append(cDay(title=day.title, courses = courses))


        return ScheduleEncoder().encode(Schedule(None, days))
