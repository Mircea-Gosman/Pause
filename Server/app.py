import flask
import Helpers.OpenCVHelpers as cvH

from flask import request
from Database.Database import db_session
from Database.StoreAccess import auth, importSchedule, updateSchedule
from flask_sqlalchemy import SQLAlchemy
from ScheduleAnalysis.Schedule import Schedule

app = flask.Flask(__name__)

@app.route('/auth', methods=['GET', 'POST'])
def authenticateUser():
    if request.method == 'POST':
        print('Authenticating.')
        return auth(request.form['key'])
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
app.run(host="0.0.0.0", port=5000, debug=True)
