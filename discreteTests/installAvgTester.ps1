if (!(test-path 'avgTest.ps1'))
{
	Write-Host "It seems that avgTest.ps1 is not in the same directory as your running file. Please do so."
}
else
{
	if (!(test-path C:\batteryTest))
	{
		mkdir C:\batteryTest
	}
	cp avgTest.ps1 C:\batteryTest\avgTest.ps1
	cp batteryConstTest.bat C:\batteryTest\startConstTest.bat
	cp batteryConstTest.lnk C:\batteryTest\batteryConstTest.lnk
	cp installAvgTesterAdmin.ps1 C:\batteryTest\installAvgTesterAdmin.ps1
	start-process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File C:\batteryTest\installAvgTesterAdmin.ps1' -Verb runas
	
	start-process powershell.exe -windowstyle hidden -file C:\batteryTest\startConstTest.bat
}