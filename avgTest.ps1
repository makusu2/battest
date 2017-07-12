function GetDataPiece #Returns a dash-separated string of seconds during discharge and percent discharge
{
    $stopwatch = New-Object -TypeName System.Diagnostics.Stopwatch 
    $stopwatch.Start()
    $startPercent = $(GetBatteryPercent)
    while ($(!($(ComputerIsPluggedIn))))
    {
        $secondsBefore = $stopwatch.Elapsed.TotalSeconds
        $percentBefore = $(GetBatteryPercent)
        $sleepTestStopwatch = New-Object -TypeName System.Diagnostics.Stopwatch
        $sleepTestStopwatch.Start()
        Start-Sleep 2
        $sleepTestSeconds = $sleepTestStopwatch.Elapsed.TotalSeconds
        if ($sleepTestSeconds -gt 30) #this means the computer had probably gone to sleep
        {
            Write-Host "The computer seems to have gone to sleep."
            $deltaPercent = $startPercent - $percentBefore
            if ($deltaPercent -lt 3)
            {
                Write-Host "The change in percentage of battery life was too small to make record of."
                return -1
            }
            $currentData = "" + $deltaPercent + "-" + $secondsBefore
            return $currentData
        }
    }
    $seconds = $stopwatch.Elapsed.TotalSeconds
    $endPercent = $(GetBatteryPercent)
    $deltaPercent = $startPercent - $endPercent
    if ($deltaPercent -lt 3)
    {
        Write-Host "The change in percentage of battery life was too small to make record of."
        return -1
    }
    $currentData = "" + $deltaPercent + "-" + $seconds
    return $currentData
}
function StartBatteryUse #Calls GetDataPiece and stores the data
{
    $dataPiece = $(GetDataPiece)
    if ($dataPiece -eq -1)
    {
        return
    }
    if (!(test-path C:\batteryTest\avgBatteryData.txt))
    {
        $dataPiece > C:\batteryTest\avgBatteryData.txt
    }
    else
    {
        $dataPiece >> C:\batteryTest\avgBatteryData.txt
    }
}

. .\helpers.ps1
if (!(test-path C:\batteryTest\))
{
    md C:\batteryTest\
}
while ($(1 -eq 1))
{
    while ($(ComputerIsPluggedIn))
    {
        Start-Sleep 2
        Write-Host "Computer is plugged in"
    }
    Write-Host "Computer has been unplugged"
    StartBatteryUse
    Write-Host "Computer has been plugged back in"
}