# -----------------------------------------------------------
# Application Flask Server Routes
#
# 2020 Mircea Gosman, Terrebonne, Canada
# email mirceagosman@gmail.com
# -----------------------------------------------------------
import flask

from flask import request
from Database.Database import db_session
from Database.StoreAccess import auth, importSchedule, updateSchedule, queryStore, notifyFriendsUpdate
from flask_sqlalchemy import SQLAlchemy
from ScheduleAnalysis.Schedule import Schedule

# Flask application 
app = flask.Flask(__name__)

# Authentication Route
@app.route('/auth', methods=['GET', 'POST'])
def authenticateUser():
    if request.method == 'POST':
        print('Authenticating.')
        return auth(request.form['key'], request.form['friendList'])
    else:
        return "Route not fit for Get requests."

# Upload schedule from the client's picture into the database
@app.route('/importSchedule', methods=['GET', 'POST'])
def importDatabaseSchedule():
    # Handle request
    if request.method == 'POST':
        print('Importing Schedule.')
        return importSchedule(request.form['key'], analyseSchedule())
    else :
        return "Route not fit for Get requests."

# Upload schedule from the client's data structures into the database
@app.route('/updateSchedule', methods=['GET', 'POST'])
def updateDatabaseSchedule():
    # Handle request
    if request.method == 'POST':
        print('Updating Schedule.')
        return updateSchedule(request.form['user'])
    else :
        return "Route not fit for Get requests."

# Download a user's schedule from the database to the client
@app.route('/querySchedule', methods=['GET', 'POST'])
def queryDatabaseSchedule():
    if request.method == 'POST':
        print('Updating Schedule.')
        return queryStore(request.form['key'])
    else :
        return "Route not fit for Get requests."

# Check if the client's friend list matches the database
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
    
    # Utilize computer vision to turn the picture into data structures
    return Schedule(imageFileName)

# Start the server (must be after all routes)
app.run(host="0.0.0.0", port=5000, debug=True, threaded=True)
