# -----------------------------------------------------------
# Database interaction module
#
# 2020 Mircea Gosman, Terrebonne, Canada
# email mirceagosman@gmail.com
# -----------------------------------------------------------
import json

from Database.Database import db_session
from Database.Models.Models import User, Day, Course
from Helpers.JSONEncoder import ScheduleEncoder

from ScheduleAnalysis.Day import Day as cDay
from ScheduleAnalysis.Course import Course as cCourse
from ScheduleAnalysis.Schedule import Schedule

# Authenticate user to the database
def auth(key, friendList):
    # Default flag for user registry
    isNew =  False

    # Check if user exists in database
    if User.query.filter_by(key=key).first() is None:
        # Add new user to Users table
        user = User(key=key)
        db_session.add(user)
        db_session.commit()

        # Create response for client
        isNew = True

        # Manage Facebook friend list syncing to database

        # Create user friendList
        friendKeyList = json.loads(friendList)

        # Browse Facebook friends
        for friendKey in friendKeyList:
            # Add friend only if he pre-exists in database
            if not (User.query.filter_by(key=friendKey).first() is None):
                establishFriendConnection(key, friendKey)

    # Answer client with registry status
    return json.dumps({'isNew' : isNew})

# Add analysed schedule to database
def importSchedule(key, schedule):
    # User reference
    user = User.query.filter_by(key=key).first()

    # Verify user validity
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

        # Return the analysed schedule in JSON
        return ScheduleEncoder().encode(schedule)

# Add received schedule from client to database
def updateSchedule(clientUser):
    clientUser = json.loads(clientUser)     # Convert user from json to map
    hasUpdated = True                       # Default flag for operation success

    # User reference
    user = User.query.filter_by(key=clientUser['key']).first()

    # Verify parameters validity
    if user is None:
        hasUpdated = False
    else:
        # Remove existing schedule data from db
        days = Day.query.filter_by(userID=user.id).all()

        # Delete old schedule data if any
        for day in days:
            # Courses reference
            courses = Course.query.filter_by(weekDay=day.id).all()

            #Browse courses
            for course in courses:
                db_session.delete(course)


            db_session.delete(day)

        # Add new client data in db
        for day in clientUser['schedule']['days']:
            # Create Day
            dbDay = Day(user = user)
            db_session.add(dbDay)

            # Create Courses
            for course in day['courses']:
                dbCourse = Course(start = course['startTime'], end = course['endTime'],
                                   text = course['text'], day = dbDay)
                db_session.add(dbCourse)

        db_session.commit()

    # Answer client with operation success status
    return json.dumps({'hasUpdated' : hasUpdated})

# Add users' references to friends table
def establishFriendConnection(key1, key2):
    # Check for existing connection
    user1 = User.query.filter_by(key=key1).first()
    user2 = User.query.filter_by(key=key2).first()

    # Default flags for database pre-existence
    connection1Exists = False
    connection2Exists = False

    # Verify if user2 is already among user1's friends
    for friend in user1.friends:
        if friend.id ==  user2.id:
            connection1Exists = True
            break

    # Verify if user1 is already among user2's friends
    for friend in user2.friends:
        if friend.id ==  user1.id:
            connection2Exists = True
            break

    # Add missing connections
    if not connection1Exists:
        user1.friends.append(user2)
        db_session.commit()

    if not connection2Exists:
        user2.friends.append(user1)
        db_session.commit()

# Respond to client polling about friend list updates
def notifyFriendsUpdate(key, friendListLength):
    clientFriends = []   # Database friends

    # User reference
    user = User.query.filter_by(key=key).first()

    # Verify user existence
    if not (user is None):
        # Verify
        if len(user.friends) != friendListLength:
            for friend in user.friends:
                clientFriends.append({'key' : friend.key})

    # Return new database friend list
    return json.dumps({'friendList' : clientFriends})


# TODO: Migrate project to heroku and setup webhooks to Facebook to receive live FB friend list updates.
# https://developers.facebook.com/docs/graph-api/webhooks/getting-started
def updateFriendList():
    print('Friend list live updates not yet available.')

# Download schedule from database to client
def queryStore(key):
    # User reference
    user = User.query.filter_by(key=key).first()

    # Verify user validity
    if user is None:
        return "Error loading user in database."
    else:
        # Query days
        dbDays = Day.query.filter_by(userID=user.id).all()

        # Transform days from db format to conventional structure
        days = []
        for day in dbDays:
            # Query courses
            dbCourses = Course.query.filter_by(weekDay=day.id).all()

            # Transform courses from db format to conventional structure
            courses = []
            for course in dbCourses:
                courses.append(cCourse(course.start, course.end, course.text))

            days.append(cDay(title=day.title, courses = courses))

        # Return the analysed schedule in JSON
        return ScheduleEncoder().encode(Schedule(None, days))
