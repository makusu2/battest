import makuUtil
import time

def initiateManualTest(type):
	blockWhileCharging()
	blockForTestStart()
	if (type == "heavy"):
		initiateStress()
	else:
		minimizeStress()
	startTime = time.time()
	while (makuUtil.batPercent() > makuUtil.testEndPercent):
		time.sleep(10)
	endTime = time.time()
	secondsPassed = endTime-startTime
	makuUtil.writeData(secondsPassed,type)
	
def blockWhileCharging():
	if (makuUtil.pluggedIn()):
		print('Battery is plugged in. Please unplug...',end="")
		while (makuUtil.pluggedIn()):
			print('.',end="")
			time.sleep(1)
		print()
	if(makuUtil.batPercent() < makuUtil.testStartPercent):
		print("Warning - Battery was not fully charged at start of test.")
	return
def blockForTestStart():
	if (makuUtil.batPercent() > makuUtil.testStartPercent):
		print("Waiting for battery to drain to "+makuUtil.testStartPercent+"%...",end="")
		while (makuUtil.batPercent() > makuUtil.testStartPercent):
			print('.',end="")
			time.sleep(1)
		print()
	return
def initiateStress():
	pass
def minimizeStress():
	pass