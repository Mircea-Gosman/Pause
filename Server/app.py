import flask
from flask import request
import houghLinesP

app = flask.Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def handle_request():
    if request.method == 'POST':
        #handle post requests with files
        imageFile = request.files['Schedule']
        imageFileName = 'schedule.'+ request.form['ext']
        imageFileText = request.form['imageText']
        imageTextBounds = request.form['linesBoundingBoxes']
        imageFile.save(imageFileName)

        houghLinesP.parseImage(imageFileName, imageFileText, imageTextBounds)
        # handle post requests with {'key' : 'value'}
        print(imageFileText)
        return "Post request handled by server succesfully."
    else :
        # handle get requests
        return "Get request handled by server succesfully."

app.run(host="0.0.0.0", port=5000, debug=True)
