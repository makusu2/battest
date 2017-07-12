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