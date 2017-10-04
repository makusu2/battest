function ManualMain
{
    param
    (
    [string]$save = $( Read-Host "Where should we save the results?" )
    [string]$mode = $( Read-Host "What mode would you like to use; heavy or light?" )
    }
	<#
	Input args:
		$save - A file location at which to save results
		$mode - Either 'heavy' or 'light'. Heavy stresses the computer, while light is for minimal stress.
	Output args: None
	Void args: Writes results of test (float value) to an appropriate file in C:\batteryTest
	#>
    if ($(test-path C:\makuTemp\location.txt))
    {
        cd $(Get-Content C:\makuTemp\location.txt)
    }
	#If a location is specified where it should be saved, go there; that's where all the scripts are
    Start-process noshutdownASADMIN.bat -verb runas
	#Ensures that the computer does not shut down
    if ($($mode -eq "heavy") )
    {
        HeavyTestVal
    }
    elseif ($($mode -eq "light"))
    {
        LightTestVal
    }
    else
    {
        Write-Host "Invalid input. Please try again."
        return
    }
    Write-Host "Test complete!"
}
function HeavyTestVal
{
    WaitForStart
    $(gwmi -ns root/wmi -class wmiMonitorBrightnessMethods).WmiSetBrightness(1,100)
	#Increase brightness to max
    $furMarkLocation = "C:\Program Files (x86)\Geeks3D\Benchmarks\FurMark\FurMark.exe"
    $furObject = Start-Process -FilePath $furMarkLocation -args "/enable_dyn_bkg=1 /bkg_img_id=2 /nogui /width=1920 /height=1080 /fullscreen /run_mode=2 /max_time=1000000000 /xtreme_burning" -PassThru
	#Start furmark
    $stopwatch = New-Object -TypeName System.Diagnostics.Stopwatch 
	#stopwatch records the time from unplugged to plugged in
    WaitForStart
	#Thread will stall on this line until the computer is unplugged
    $stopwatch.Start()
    while ($(GetBatteryPercent) -gt 10)
    {
        Start-Sleep 10
        $currentSeconds = $stopwatch.Elapsed.TotalSeconds
        $currentSeconds > C:\batteryTest\heavyResultSeconds.txt
		#Value keeps being overwritten; last value should be the value at 10% battery.
    }
    Stop-Process $furObject
	#Closing furmark. Not necessary.
	$stopwatch.Elapsed.TotalSeconds
	#Last declaration is the total seconds, in case it should be used as a return argument.
}
function LightTestVal
{
    WaitForStart
    $(gwmi -ns root/wmi -class wmiMonitorBrightnessMethods).WmiSetBrightness(1,0)
	#Decrease brightness to minimum
    $stopwatch = New-Object -TypeName System.Diagnostics.Stopwatch 
	#stopwatch records the time from unplugged to plugged in
    WaitForStart
	#Thread will stall on this line until the computer is unplugged
    $stopwatch.Start()
    while ($(GetBatteryPercent) -gt 10)
    {
        Start-Sleep 10
        $currentSeconds = $stopwatch.Elapsed.TotalSeconds
        $currentSeconds > C:\batteryTest\lightResultSeconds.txt
		#Value keeps being overwritten; last value should be the value at 10% battery.
    }
    $stopwatch.Elapsed.TotalSeconds
	#Last declaration is the total seconds, in case it should be used as a return argument.
}
function WaitForStart
{
	#Stalls until computer is unplugged and a session can begin
    while ($(ComputerIsPluggedIn))
    {
        Write-Host "Waiting for computer to be unplugged..."
        Start-Sleep 1
    }
    if ($(GetBatteryPercent) -lt 99)
    {
        Write-Host "Warning - Battery is not fully charged at start of test"
    }
}


function GetBatteryPercent
{
    $batteryPercent = (gwmi win32_battery).estimatedChargeRemaining
    return $batteryPercent
}
function ComputerIsPluggedIn
{
    $unplugged = $($(gwmi win32_battery).BatteryStatus -eq 1)
    return $(!($unplugged))
}