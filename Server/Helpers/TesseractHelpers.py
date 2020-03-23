import pytesseract

from pytesseract import Output
from ScheduleAnalysis.Line import Line

def readScheduleTextLines(scheduleImg, config=None):
    if config is None:
        imageData= pytesseract.image_to_data(scheduleImg, lang = 'fra',output_type=Output.DICT)
    else:
        imageData= pytesseract.image_to_data(scheduleImg, lang = 'fra',output_type=Output.DICT, config=r'--psm '+config)
    textLines = []

    for i in range(len(imageData['level'])):
        if int(imageData['conf'][i]) != -1:
            (x, y, w, h) = (imageData['left'][i], imageData['top'][i], imageData['width'][i], imageData['height'][i])
            if w>=h:
                textLines.append(Line([x,y], w, h, imageData['text'][i]))

    return textLines
