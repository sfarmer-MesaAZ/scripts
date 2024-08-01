param([Switch]$WaitForKey)

if (([Version](Get-CimInstance Win32_OperatingSystem).version).Major -lt 10)
{
    Write-Host -ForegroundColor Red "The DeveloperMode is only supported on Windows 10"
    exit 1
}

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

if ($myWindowsPrincipal.IsInRole($adminRole))
{
    $RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (! (Test-Path -Path $RegistryKeyPath)) 
    {
        New-Item -Path $RegistryKeyPath -ItemType Directory -Force
    }

    if (! (Get-ItemProperty -Path $RegistryKeyPath -Name AllowDevelopmentWithoutDevLicense))
    {
        # Add registry value to enable Developer Mode
        New-ItemProperty -Path $RegistryKeyPath -Name AllowDevelopmentWithoutDevLicense -PropertyType DWORD -Value 1
    }
    $feature = Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online
    if ($feature -and ($feature.State -eq "Disabled"))
    {
        Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -All -LimitAccess -NoRestart
    }

    if ($WaitForKey)
    {
        Write-Host -NoNewLine "Press any key to continue..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}
else
{
   # We are not running "as Administrator" - so relaunch as administrator
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

   # Specify the current script path and name as a parameter
   $newProcess.Arguments = "-NoProfile",$myInvocation.MyCommand.Definition,"-WaitForKey";

   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";

   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);

   # Exit from the current, unelevated, process
   exit
}