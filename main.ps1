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
cd $(Get-Content C:\makuTemp\location.txt)
Start-process noshutdownASADMIN.bat -verb runas
powershell .\fullTest.ps1