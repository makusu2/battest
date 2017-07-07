import plotly.plotly as plotter
import plotly.graph_objs as go
import numpy as np
from tkinter import filedialog
import xml.etree.ElementTree as ET


class DataPoint:
    def __init__(self, id, dataDict):
        self.id = id
        self.dataDict = dataDict
        
#So first, import data.
#Then, ask user for the axes, maybe?
def getPoints():
    xmlDoc = filedialog.askopenfilename(title="Please open the XML file of the data points.")
    tree = ET.parse(xmlDoc)
    root=tree.getroot()
    points = []
    for child in root:
        idDict = child.attrib
        if not idDict: continue
        #print("idDict: "+str(idDict))
        idStr = idDict['id']
        id = int(idStr)
        dataDict = dict()
        for childElement in child:
            dataDict[childElement.tag] = childElement.text
            try:
                #print("0")
                floated = float(dataDict[childElement.tag])
                dataDict[childElement.tag] = floated
            except ValueError:
                #print("1")
                pass
        newPoint = DataPoint(id,dataDict)
        points.append(newPoint)
    return points
points = getPoints()
numericLists = dict()
for point in points:
    for key in point.dataDict:
        value = point.dataDict[key]
        if isinstance(value, float):
            if key in numericLists:
                numericLists[key].append(value)
            else:
                numericLists[key] = [value]
#for key in numericLists:
#    value = numericLists[key]
#    print(str(key)+": "+str(len(value)))

yvar = numericLists['batteryPercent']
xvar = list(range(0,len(yvar)))
#print(str(xvar))
#print(str(yvar))
trace = go.Scatter(x=xvar,y=yvar)
data=[trace]
plotter.plot(data,filename='thingie')