function HeavyTestVal
{
    $originalBatteryPercent = GetBatteryPercent
    
    
    
    $(gwmi -ns root/wmi -class wmiMonitorBrightnessMethods).WmiSetBrightness(1,100)
    $numCores = $(gwmi win32_processor).NumberOfCores
    $furMarkLocation = "C:\Program Files (x86)\Geeks3D\Benchmarks\FurMark\FurMark.exe"
    $furObject = Start-Process -FilePath $furMarkLocation -args "/enable_dyn_bkg=1 /bkg_img_id=2 /nogui /width=1920 /height=1080 /fullscreen /run_mode=2 /max_time=1000000000 /xtreme_burning" -PassThru
    
    while ($(GetBatteryPercent) -eq $originalBatteryPercent) #Should work as function
    {
        Start-Sleep 1
    }
    $stopwatch = New-Object -TypeName System.Diagnostics.Stopwatch 
    $stopwatch.Start()
    while ($($originalBatteryPercent - $(GetBatteryPercent)) -lt 2)
    {
        Start-Sleep 1
    }
    $totalSeconds = $stopwatch.Elapsed.TotalSeconds
    Stop-Process $furObject
    return $totalSeconds
}
function GetBatteryPercent
{
    $batteryPercent = (gwmi win32_battery).estimatedChargeRemaining
    return $batteryPercent
}
function MinSettings #DO MORE HERE
{
    $(gwmi -ns root/wmi -class wmiMonitorBrightnessMethods).WmiSetBrightness(1,0)
}


$unplugged = $($(gwmi win32_battery).BatteryStatus -eq 1)
if (!($unplugged))
{
    Write-Host "Warning: Computer is plugged in"
}
$timeTaken = HeavyTestVal
$timeTaken > heavyResult.txt

function HeavyTest

#Maybe start at 100, wait until 90, then run until 10