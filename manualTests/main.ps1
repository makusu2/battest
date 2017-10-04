#DO NOT RUN THIS FILE. It is only for debugging.



if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) 
{
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) 
    {
        if (!(test-path C:\makuTemp\))
        {
            md -path C:\makuTemp\
        }
        $pwd.path > C:\makuTemp\location.txt
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}
#Running as admin if not already
cd $(Get-Content C:\makuTemp\location.txt)
Start-process noshutdownASADMIN.bat -verb runas
#Prevents sleep/shutdown/etc (so that computer stays awake during test)
powershell .\fullTest.ps1
#Run the test