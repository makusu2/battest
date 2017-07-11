function HeavyTestVal
{
    WaitForStart
    $(gwmi -ns root/wmi -class wmiMonitorBrightnessMethods).WmiSetBrightness(1,100)
    $furMarkLocation = "C:\Program Files (x86)\Geeks3D\Benchmarks\FurMark\FurMark.exe"
    $furObject = Start-Process -FilePath $furMarkLocation -args "/enable_dyn_bkg=1 /bkg_img_id=2 /nogui /width=1920 /height=1080 /fullscreen /run_mode=2 /max_time=1000000000 /xtreme_burning" -PassThru
    $stopwatch = New-Object -TypeName System.Diagnostics.Stopwatch 
    WaitForStart
    $stopwatch.Start()
    while ($(GetBatteryPercent) -gt 10)
    {
        Start-Sleep 10
        $currentSeconds = $stopwatch.Elapsed.TotalSeconds
        $currentSeconds > heavyResultSeconds.txt
    }
    Stop-Process $furObject
}
function LightTestVal
{
    WaitForStart
    $(gwmi -ns root/wmi -class wmiMonitorBrightnessMethods).WmiSetBrightness(1,0)
    $stopwatch = New-Object -TypeName System.Diagnostics.Stopwatch 
    WaitForStart
    $stopwatch.Start()
    while ($(GetBatteryPercent) -gt 10)
    {
        Start-Sleep 10
        $currentSeconds = $stopwatch.Elapsed.TotalSeconds
        $currentSeconds > lightResultSeconds.txt
    }
    $stopwatch.Elapsed.TotalSeconds
}
function WaitForStart
{

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




$testVal = Read-Host -Prompt "Would you like to run a heavy test (1) or a light test (2)?"
if ($testVal -eq 1)
{
    HeavyTestVal
}
elseif ($testVal -eq 2)
{
    LightTestVal
}
else
{
    Write-Host "Invalid input. Please try again."
}
Write-Host "Test complete!"