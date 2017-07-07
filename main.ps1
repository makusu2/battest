function TakeData
{
    $dataFile = makeNewDataFile
    $relativeTime = (New-TimeSpan -Start "01/01/1970").TotalSeconds
    $batteryPercent = (gwmi win32_battery).estimatedChargeRemaining #This should be improved; not enough precision
    $cpuGhz = (gwmi win32_processor).CurrentClockSpeed
    $totalMemory = $(gwmi win32_OperatingSystem).TotalVisibleMemorySize
    $usedMemory = @($totalMemory - $(gwmi win32_OperatingSystem).FreePhysicalMemory)
    $brightnessPercent = $(Get-Ciminstance -Namespace root/WMI -ClassName WmiMonitorBrightness).CurrentBrightness
    $wifiEnabled = $($(Get-NetAdapter | where {$_.ifAlias -eq "Wi-Fi"} | where {$_.Status -eq "Connected"}) -contains "Wi-Fi")
    $temp = Get-Temperature
    $unplugged = $($(gwmi win32_battery).BatteryStatus -eq 1)
    $bytesPerSec = GetBytesPerSec
    
    "relativeTime=" + $relativeTime >> $dataFile
    "batteryPercent=" + $batteryPercent >> $dataFile
    "cpuGhz=" + $cpuGhz >> $dataFile
    "totalMemory=" + $totalMemory >> $dataFile
    "usedMemory=" + $usedMemory >> $dataFile
    "brightnessPercent=" + $brightnessPercent >> $dataFile
    "wifiEnabled=" + $wifiEnabled >> $dataFile
    "temp=" + $temp >> $dataFile
    "unplugged=" + $unplugged >> $dataFile
    "bytesPerSec=" + $bytesPerSec >> $dataFile
}
function makeNewDataFile
{
    $dataFolder = "C:\makuTemp\batData"
    $numData = $("{0:D8}" -f $(1 + $(get-content $($dataFolder + "\numData.txt"))))
    $date = get-date -format "MM/dd/yyyy HH:mm" #To get the date from this, do <get-date -date $nameOfString>
    $dataName = $("point" + $numData + ".log")
    $dataFile = $($dataFolder + "\" + $dataName)
    "id=" + $numData > $dataFile
    "date=" + $date >> $dataFile
    $numData > $($dataFolder + "\numData.txt")
    return $dataFile
}
function GetDataFolder { $dataFolder = "C:\makuTemp\batData"; return $dataFolder }
function Get-Temperature #https://stackoverflow.com/questions/39738494/get-cpu-temperature-in-cmd-power-shell
{
    $t = gwmi MSAcpi_ThermalZoneTemperature -Namespace "root/wmi"
    $rawTemp = $t.CurrentTemperature[0]
    $returnTemp = $($rawTemp/10) - 273.15
    return $returnTemp
}
function GetBytesPerSec
{
    $totalBytes = 0
    $numTrials = 5
    $interfaces = gwmi -class Win32_PerfFormattedData_Tcpip_NetworkInterface
    $interfaceIndex = -1
    for ($i=0; $i -lt $interfaces.Count; $i++)
    {
        if ($interfaces[$i].BytesTotalPersec -gt 0)
        {
            $interfaceindex = $i
        }
    }
    $adapterName = $($interfaces | where {$_.PacketsPersec -gt 0}).Name
    if ($interfaceIndex -eq -1)
    {
        $avgBytes = 0
    }
    else
    {
        for ($i=0;$i -lt $numTrials; $i++)
        {
            $totalBytes += $(gwmi -class Win32_PerfFormattedData_Tcpip_NetworkInterface)[$interfaceIndex].BytesTotalPersec
        }
        $avgBytes = $totalBytes / $numTrials
    }
    return $avgBytes
}
function Adminize
{
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
    { 
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit 
    }
}
function OrganizeToXML
{
    $dataFolder = GetDataFolder
    $txtFiles = Get-ChildItem $dataFolder -Filter point*
    $xmlName = $dataFolder + "\allPoints.xml"
    $xmlDoc = [System.Xml.XmlDocument](Get-Content $xmlName)
    for ($i=0; $i -lt $txtFiles.Count; $i++)
    {
        AddTxtToXml $($txtFiles[$i]) $xmlDoc
    }
    $xmlDoc.Save($xmlName)
}
function AddTxtToXml
{
    $txtFile = $args[0]
    $xmlDoc = $args[1]
    
    $content = Get-Content $txtFile.FullName
    
    $newXmlPointElement = $xmlDoc.CreateElement("point")
    $newXmlPoint = $xmlDoc.points.AppendChild($newXmlPointElement)
    
    foreach ($thing in $content)
    {
        $var = $thing.Split('=')
        if ($var[0] -eq "id")
        {
            $newXmlPoint.SetAttribute("id",$var[1])
        }
        else
        {
            $newXmlPoint.AppendChild($xmlDoc.CreateElement($var[0])).AppendChild($xmlDoc.CreateTextNode($var[1])) | out-null
        }
    }
}
Adminize
$dataFolder = GetDataFolder
$numDataFile = $dataFolder + "\numData.txt"
for(;;)
{
    $numData = $("{0:D8}" -f $(1 + $(get-content $numDataFile)))
    TakeData
    $numData > $numDataFile
    if ($($numData % 10) -eq 0)
    {
        OrganizeToXML
        Remove-Item $($dataFolder+"\point*")
    }
    Start-Sleep 60
}