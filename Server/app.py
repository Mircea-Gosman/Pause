import flask
import Helpers.OpenCVHelpers as cvH

from flask import request
from Database.Database import db_session
from Database.StoreAccess import auth, importSchedule, updateSchedule, notifyFriendsUpdate
from flask_sqlalchemy import SQLAlchemy
from ScheduleAnalysis.Schedule import Schedule

app = flask.Flask(__name__)

@app.route('/auth', methods=['GET', 'POST'])
def authenticateUser():
    if request.method == 'POST':
        print('Authenticating.')
        return auth(request.form['key'], request.form['friendList'])
    else:
        return "Route not fit for Get requests."

@app.route('/importSchedule', methods=['GET', 'POST'])
def importDatabaseSchedule():
    # Handle request
    if request.method == 'POST':
        print('Importing Schedule.')
        return importSchedule(request.form['key'], analyseSchedule())
    else :
        return "Route not fit for Get requests."

@app.route('/updateSchedule', methods=['GET', 'POST'])
def updateDatabaseSchedule():
    # Handle request
    if request.method == 'POST':
        print('Updating Schedule.')
        return updateSchedule(request.form['user'])
    else :
        return "Route not fit for Get requests."

@app.route('/downloadFriends', methods=['GET', 'POST'])
def downloadFriends():
    if request.method == 'POST':
        print('Looking for friend list updates.')
        return notifyFriendsUpdate(request.form['key'], request.form['friendListLength'])
    else :
        return "Route not fit for Get requests."

# Stop database sessions
@app.teardown_appcontext
def shutdown_session(exception=None):
    db_session.remove()

# Extract and organize text from image
def analyseSchedule():
    # Save File
    imageFile = request.files['Schedule']
    imageFileName = 'schedule.'+ request.form['ext']
    imageFile.save(imageFileName)

    # Create schedule Object
    topLeft, width, height = cvH.findScheduleBounds(imageFileName)
    schedule = Schedule(imageFileName, topLeft, width, height)

    return schedule

# Start the server (must be after all routes)
app.run(host="0.0.0.0", port=5000, debug=True, threaded=True)

# Implementing SSE if ever needed :: No use found bc broadcast is made to all subs; currently using client long polling instead.
# https://medium.com/code-zen/python-generator-and-html-server-sent-events-3cdf14140e56
# https://stackoverflow.com/questions/12232304/how-to-implement-server-push-in-flask-framework
# https://pub.dev/documentation/eventsource/latest/
