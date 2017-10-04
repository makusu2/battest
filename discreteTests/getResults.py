'''
Steven Pitts
Maku
10/4/17
Wentworth Institute of Technology DTS

Input args: None
Output args: None
Void args: Prints the minutes per percent

Warning: The PowerShell write statement is dumb and may encode the file in different ways. If you get an error with the data and it looks fine in a text editor, that's probably why. 
If that happens, you must change the encoding manually. This can be accomplished by opening the file in notepad++ and using the "encoding" tab to convert it to UTF-8.

'''

import os
from tkinter import filedialog



def getData():
	'''
	returns a generator of data tuples. tuple[0] should return the change in percent over a session, and tuple[1] should return the seconds that passed during the session.
	'''
	defaultLocation = r'C:\batteryTest\avgBatteryData.txt'
	#r means 'read it exactly', without escape characters
	batDataFile = None
	if os.path.exists(defaultLocation):
		batDataFile = open(defaultLocation,'r')
	else:
		batDataFile = open(filedialog.askopenfilename(title='Please select the data file'),'r')

	for line in batDataFile.read().splitlines():
		splitLine = line.strip().split('-')
		lineInts = tuple(float(num) for num in splitLine)
		yield lineInts

def main():
	data = tuple(getData())
	deltaPercentSum = sum([pair[0] for pair in data])
	deltaMinuteSum = sum([pair[1]/60 for pair in data])
	minsPerPercent = deltaMinuteSum/deltaPercentSum
	print("minsPerPercent: "+str(minsPerPercent))

main()