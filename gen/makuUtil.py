import psutil
import time
import pathlib
from sys import platform
import os

assert hasattr(psutil,'sensors_battery'),'Hardware does not support battery-related methods'

testStartPercent = 95
testEndPercent = 5
mainDir = r"C:/batteryTest/" if platform == "win32" else r"/batteryTest/"
dataFiles = {'light':'light.dat','heavy':'heavy.dat','discrete':'discrete.dat'}


def batPercent():
	return psutil.sensors_battery().percent
def pluggedIn():
	return psutil.sensors_battery().power_plugged
def ensureMainDirExists():
	if not os.path.exists(mainDir):
		pathlib.Path(mainDir).mkdir(parents=True, exist_ok=True)

def writeData(data,testType):
	log("Writing data: "+data)
	ensureMainDirExists()
	fileLocation = mainDir+dataFiles[testType]
	with open(fileLocation,'a') as f:
		f.write(data+"\n")
		#Warning - Doesn't overwrite. This should only be a problem if the same test is run twice, in which case the user might want multiple pieces of data.
		#Also, there will be a blank line at the end
def log(s):
	print(s)
	ensureMainDirExists()
	fileLocation = mainDir+"log.txt"
	with open(fileLocation,'a') as f:
		f.write(s+"\n")