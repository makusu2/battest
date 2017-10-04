<#
Steven Pitts
Maku
10/4/17
Wentworth Institute of Technology DTS

Input args: None
Output args: None
Void args: After each session of the laptop being unplugged, writes 'percent-seconds' to C:\batteryTest\avgBatteryData.txt, where percent is the change in battery percent and seconds are the number of seconds that passed during the session.

Warning: The PowerShell write statement is dumb and may encode the file in different ways.

#>
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
        #$dataPiece > C:\batteryTest\avgBatteryData.txt
		write-output $dataPiece | out-file -encoding ascii C:\batteryTest\avgBatteryData.txt
		#Not writing in ascii if I don't
    }
    else
    {
        write-output $dataPiece | out-file -encoding ascii -append C:\batteryTest\avgBatteryData.txt
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