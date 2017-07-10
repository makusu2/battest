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
def getPercentAverages(points):
    numericLists = dict()
    for point in points:
        for key in point.dataDict:
            value = point.dataDict[key]
            if isinstance(value, float):
                if key in numericLists:
                    numericLists[key].append(value)
                else:
                    numericLists[key] = [value]
    percentsPossible = list(set(numericLists['batteryPercent']))
    percentCounts = {percent:numericLists['batteryPercent'].count(percent) for percent in percentsPossible} 
    percentTotals = {percent:{val:0 for val in numericLists if not (val == 'batteryPercent')} for percent in percentsPossible}
    #print(percentTotals)
    print("ieoga     "+str(len(numericLists['batteryPercent'])))
    for i in range(len(points)):
        #print("ITHING   "+str(i))
        batteryPercent = numericLists['batteryPercent'][i]
        for valKey in numericLists:
            if valKey == 'batteryPercent':
                continue
            valList = numericLists[valKey]
            val = valList[i]
            #print(batteryPercent)
            #print(valKey)
            percentTotals[batteryPercent][valKey] += val
    #print(percentTotals)
    percentAvgs = {percent:{val:percentTotals[percent][val]/percentCounts[percent] for val in percentTotals[percent]} for percent in percentsPossible}
    for percent in percentsPossible:
        percentAvgs[percent]['count'] = percentCounts[percent]
    return percentAvgs
    #print(percentAvgs)
points = getPoints()
avgs = getPercentAverages(points)
attribs = [att for att in avgs[list(avgs.keys())[0]]]
valLists = {val:[] for val in attribs}
for percent in avgs:
    for val in avgs[percent]:
        valLists[val].append(avgs[percent][val])
#print(valLists)
    
#counts = [avgs[percent]['count'] for percent in avgs]

desiredY = 'usedMemory'

xvar = valLists['usedMemory']
yvar = valLists['count']
#print(str(xvar))
#print(str(yvar))
trace = go.Scatter(x=xvar,y=yvar,mode='markers')
data=[trace]
plotter.plot(data,filename='thingie')