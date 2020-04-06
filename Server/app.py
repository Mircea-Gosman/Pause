import flask
import Helpers.OpenCVHelpers as cvH

from flask import request
from Database.Database import db_session
from Database.StoreAccess import createUser, updateStore, queryStore
from flask_sqlalchemy import SQLAlchemy
from ScheduleAnalysis.Schedule import Schedule

app = flask.Flask(__name__)

@app.route('/test', methods=['GET', 'POST'])
def handle_request():
    # Greet
    print('Welcome.')

    # Handle request
    if request.method == 'POST':
        # Check if new user
        #if request.form['id'] == 'new':
        if True:
            createUser(analyseSchedule())
            return "New user succesfully registered in Database."
        else:
            # Check if user is in database
            if userInDatabase(request.form['id']):
                # if request.form['update'] == 'true':
                updateStore(request.form)
                # elif request.form['read'] == 'true':
                # queryStore(request.form)
                return "Recurring user database access validated."
            else:
                return "Invalid user database access attempt."

    else :
        return "Get request handled by server succesfully."

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

    return schedule.days

# Start the server (must be after all routes)
app.run(host="0.0.0.0", port=5000, debug=True)
