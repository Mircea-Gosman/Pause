import flask
from flask import request
from ImageData import ImageInfo
from ServerOCR.OCR import OCR

app = flask.Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def handle_request():
    if request.method == 'POST':
        #handle post requests with files
        # Save file
        imageFile = request.files['Schedule']
        imageFileName = 'schedule.'+ request.form['ext']
        imageFile.save(imageFileName)
        print('hello')
        # Hold extracted data
        imageInfo = ImageInfo(request.form['coordinates'], request.form['linesText'], imageFileName)

        # handle post requests with {'key' : 'value'}
        return "Post request handled by server succesfully."
    else :
        # handle get requests
        return "Get request handled by server succesfully."

app.run(host="0.0.0.0", port=5000, debug=True)
