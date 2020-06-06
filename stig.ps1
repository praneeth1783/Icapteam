#---------------------Feature 9-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#..............................................................................................................................................................................................................................
# Vul ID:-1089
#...............................................................................................................................................................................................................................
Write-Host "Executing STIG Fix for Vul ID:-1089 `n"
$Message = "You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only.

By using this IS (which includes any device attached to this IS), you consent to the following conditions:

-The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations.

-At any time, the USG may inspect and seize data stored on this IS.

-Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG-authorized purpose.

-This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy.

-Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details.

Fix Text: Configure the policy value for Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> Security Options >> 'Interactive Logon: Message text for users attempting to log on' to the following:

You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only.

By using this IS (which includes any device attached to this IS), you consent to the following conditions:

-The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations.

-At any time, the USG may inspect and seize data stored on this IS.

-Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG-authorized purpose.

-This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy.

-Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details.


"

$value = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name legalnoticetext -ErrorAction SilentlyContinue
    
if($value -eq $null) 
{
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LegalNoticeText -Value $Message
     
}
else
{
    Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name legalnoticetext 
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LegalNoticeText -Value $Message
}
#.......................................................................................................................................................................................................................................
#.......................................................................................................................................................................................................................................
# Vul ID:- 3383
#.......................................................................................................................................................................................................................................
Write-Host "Executing STIG Fix for Vul ID:-3383 `n"
$value = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy -Name Enabled -ErrorAction SilentlyContinue

if($value -ne $null -and $value.Enabled -eq 0)
{
    Remove-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy -Name Enabled
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy -Name Enabled -Value 1 -Type DWord
}
elseif($value -eq $null)
{
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy -Name Enabled -Value 1 -Type DWord
}
#..............................................................................................................................................................................................................................................
#----------------------------------------------------------Feature 10------------------------------------------------------------------------------------------------------------------------------------------------------------------
#.......................................................................................................................................................................................................................................
# Vul ID:- 1097
#.......................................................................................................................................................................................................................................
Write-Host "Executing STIG Fix for Vul ID:-1097 `n"
cmd.exe /c "net accounts /lockoutthreshold:3"
#..............................................................................................................................................................................................................................................
#.......................................................................................................................................................................................................................................
# Vul ID:- 1098 and 1099
#.......................................................................................................................................................................................................................................
Write-Host "Executing STIG Fix for Vul ID:-1098 and Vul ID:-1099 `n"
cmd.exe /c "net accounts /lockoutduration:30"
cmd.exe /c "net accounts /lockoutwindow:15"
#..............................................................................................................................................................................................................................................
#.......................................................................................................................................................................................................................................
# Vul ID:- 1104
#.......................................................................................................................................................................................................................................
Write-Host "Executing STIG Fix for Vul ID:-1104 `n"
cmd.exe /c "net accounts /maxpwage:60"
#..............................................................................................................................................................................................................................................
#.......................................................................................................................................................................................................................................
# Vul ID:- 1105
#.......................................................................................................................................................................................................................................
Write-Host "Executing STIG Fix for Vul ID:-1105 `n"
cmd.exe /c "net accounts /minpwage:1"
#..............................................................................................................................................................................................................................................
#.......................................................................................................................................................................................................................................
# Vul ID:- 1107
#.......................................................................................................................................................................................................................................
Write-Host "Executing STIG Fix for Vul ID:-1107 `n"
cmd.exe /c "net accounts /uniquepw:24"
#..............................................................................................................................................................................................................................................
#.......................................................................................................................................................................................................................................
# Vul ID:- 6836
#.......................................................................................................................................................................................................................................
Write-Host "Executing STIG Fix for Vul ID:-6836 `n"
#cmd.exe /c "net accounts /minpwlen:14" #.....Uncomment when deployed to actual product
#..............................................................................................................................................................................................................................................
#--------------------------------------- Feature 13 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#.......................................................................................................................................................................................................................................
# Vul ID:- 3449
#.......................................................................................................................................................................................................................................
Write-Host "Executing STIG Fix for Vul ID:-6836 `n"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fSingleSessionPerUser  -Value 1 -Type DWord
#..............................................................................................................................................................................................................................................
#.......................................................................................................................................................................................................................................
# Vul ID:- 14249
#.......................................................................................................................................................................................................................................
Write-Host "Executing STIG Fix for Vul ID:-14249 `n"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name fDisableCdm  -Value 1 -Type DWord
#..............................................................................................................................................................................................................................................
#--------------------------------------- Feature 11------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#.......................................................................................................................................................................................................................................
# Vul ID:- 80477..................This is for win 2012/2012 R2
#.......................................................................................................................................................................................................................................
#if(Get-WindowsFeature -Name PowerShell-v2)
#{
#    Uninstall-WindowsFeature -Name PowerShell-v2
#}
#...................................................................................................................................................................
# Vul ID:- 78059 (1)
#.......................................................................................................................................................................................................................................
cmd /c "AuditPol /set /category:"Logon/Logoff" /subcategory:"Account Lockout" /failure:enable /success:disable"

#(2)

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -Name ProcessCreationIncludeCmdLine_Enabled  -Value 1 -Type DWord

#(3)
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name InactivityTimeoutSecs  -Value 900 -Type DWord


# Vul ID:- 36707
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name EnableSmartScreen  -Value 1 -Type DWord

# Vul ID:- 26602

$value = Get-Service -Name FTPSVC -ErrorAction SilentlyContinue
if($value -ne $null)
{
     Stop-Service -Name FTPSVC -Force -ErrorAction SilentlyContinue
}

#  Vul ID:- 26576
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition\IPHTTPS\IPHTTPSInterface" -Name IPHTTPS_ClientState  -Value 3 -Type DWord


#----------------------------------------Feature 12-----------------------
#  Vul ID:- 14234
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name FilterAdministratorToken  -Value 1 -Type DWord

#  Vul ID:- 14235
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name ConsentPromptBehaviorAdmin  -Value 4 -Type DWord
# vul ID:- 14236
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name ConsentPromptBehaviorUser  -Value 0 -Type DWord
#Vul ID- 14240
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA  -Value 1 -Type DWord




