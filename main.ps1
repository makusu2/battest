function TakeData
{
    $dataFile = makeNewDataFile
    $relativeTime = (New-TimeSpan -Start "01/01/1970").TotalSeconds
    $batteryPercent = (gwmi win32_battery).estimatedChargeRemaining #This should be improved; not enough precision
    $cpuGhz = (gwmi win32_processor).CurrentClockSpeed
    $totalMemory = $(gwmi win32_OperatingSystem).TotalVisibleMemorySize
    $usedMemory = @($totalMemory - $(gwmi win32_OperatingSystem).FreePhysicalMemory)
    $brightnessPercent = $(Get-Ciminstance -Namespace root/WMI -ClassName WmiMonitorBrightness).CurrentBrightness
    
    "relativeTime=" + $relativeTime >> $dataFile
    "batteryPercent=" + $batteryPercent >> $dataFile
    "cpuGhz=" + $cpuGhz >> $dataFile
    "totalMemory=" + $totalMemory >> $dataFile
    "usedMemory=" + $usedMemory >> $dataFile
    "brightnessPercent=" + $brightnessPercent >> $dataFile
}
function makeNewDataFile
{
    $dataFolder = "C:\makuTemp\batData"
    $numData = $("{0:D8}" -f $(get-content $($dataFolder + "\numData.txt")))
    $date = get-date -format "MM/dd/yyyy HH:mm" #To get the date from this, do <get-date -date $nameOfString>
    $dataName = $("point" + $numData + ".log")
    $dataFile = $($dataFolder + "\" + $dataName)
    $date > $dataFile
    $(1 + $numData) > $($dataFolder + "\numData.txt")
    return $dataFile
}
function getData #This is JUST FOR TESTING
{
    Get-Content file.txt | Foreach-Object
    {
        $var = $_.Split('=')
        New-Variable -Name $var[0] -Value $var[1]
    }
}

for(;;)
{
    TakeData
    Start-Sleep 2
}