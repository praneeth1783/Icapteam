try {
    # Getting the NLA information
    $NLAStatus = (Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -ComputerName localhost -Filter "TerminalName='RDP-tcp'").UserAuthenticationRequired
    "NLA status is $NLAStatus"
    if(!$NLAStatus)
    {
        "Setting the NLA information to Enabled"
        (Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -ComputerName localhost -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(1)
    }
}
catch {
    "Message: $($_.Exception.Message)"
    "StackTrace: $($_.Exception.StackTrace)"
    "LoaderExceptions: $($_.Exception.LoaderExceptions)"
    Write-Error "$($_.Exception.Message)"
    exit 1
}