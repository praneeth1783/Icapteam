Try
{
    #Get script directory. To support PS ver 2.0 we are not using $PSScriptRoot..
    $scriptPath= split-path -Parent $MyInvocation.MyCommand.Definition
    $Path = $scriptPath | Split-Path
    $PortalInstallationFolder = $Path

    #icacls $PortalInstallationFolder /inheritancelevel:d /T

    icacls $PortalInstallationFolder /remove:g "Everyone" /T

    icacls $PortalInstallationFolder /grant:r `"Authenticated Users`":`(OI`)`(CI`)RXWM /T


}
Catch
{
    "Message: $($_.Exception.Message)"
    "StackTrace: $($_.Exception.StackTrace)"
    "LoaderExceptions: $($_.Exception.LoaderExceptions)"
    Write-Error "$($_.Exception.Message)"
    exit 1
}

Write-Host "Press any key to continue..."
