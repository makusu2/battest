function HeavyTestVal
{
    $originalBatteryPercent = GetBatteryPercent
    MaxSettings
   
    while (GetBatteryPercent -eq $originalBatteryPercent) #Should work as function
    {
        Start-Sleep 10
    }
    $startSeconds = (New-TimeSpan -Start "01/01/1970").TotalSeconds
    while ($($originalBatteryPercent - $batteryPercent) -lt 5)
    {
        Start-Sleep 10
    }
    $endSeconds = (New-TimeSpan -Start "01/01/1970").TotalSeconds
    $totalSeconds = $endSeconds - $startSeconds
    return $totalSeconds
}
function GetBatteryPercent
{
    $batteryPercent = (gwmi win32_battery).estimatedChargeRemaining
    return $batteryPercent
}
function MaxSettings#DO MORE HERE
{
    $(gwmi -ns root/wmi -class wmiMonitorBrightnessMethods).WmiSetBrightness(1,100)
}
function MinSettings#DO MORE HERE
{
    $(gwmi -ns root/wmi -class wmiMonitorBrightnessMethods).WmiSetBrightness(1,0)
}


$unplugged = $($(gwmi win32_battery).BatteryStatus -eq 1)