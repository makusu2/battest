import makuUtil
import time

log = makuUtil.log

def getDataPiece():
	'''
	Called when computer is unplugged
	Input args: None
	Output args: 
		Failure: Returns -1 (data was recognized as not useful)
		Success: Returns a string of "<deltaPercent>-<deltaSeconds>"
			deltaPercent: Percent of battery life drained since the function was called
			deltaSeconds: Number of seconds that have passed since the function was called
			Example: "5.23-15.8587"
	Void args: None
	'''
	def getReturnVal(deltaPercent,deltaSeconds):
		log("Getting return val for "+str(deltaPercent)+" percent, "+str(deltaSeconds)+" seconds")
		if(deltaPercent<3):
			#Fail; not enough data collected
			log("Data piece fail")
			return None
		else:
			log("Data piece success")
			return str(deltaPercent)+"-"+str(deltaSeconds)
			
	assert(not makuUtil.pluggedIn()), "Tried to get data piece while computer was plugged in"
	secondsStart = time.time()
	startPercent = makuUtil.batPercent()
	while(not makuUtil.pluggedIn()):
		secondsBeforeSleep = time.time()
		#Using two different seconds variables to test if computer has gone to sleep
		time.sleep(10)
		secondsAfterSleep = time.time()
		if (secondsAfterSleep-secondsBeforeSleep > 20):
			#This means the computer has likely gone to sleep
			return getReturnVal(startPercent-makuUtil.batPercent(),secondsBeforeSleep-secondsStart)
		pass
	return getReturnVal(startPercent-makuUtil.batPercent(),time.time()-secondsStart)
def contTest():
	while True: #Should always be running
		log("Back at start of infinite loop")
		while (makuUtil.pluggedIn()):
			log("Computer recognized as being plugged in")
			time.sleep(10)
			#Wait for computer to be unplugged so that a test can be run
		log("Computer recognized as being unplugged")
		dataPiece = getDataPiece() #Blocking
		log("Data piece obtained")
		if dataPiece:
			#If it's not None
			log("Data piece was not none")
			makuUtil.writeData(dataPiece,"discrete")
			log("Data piece written")
contTest()