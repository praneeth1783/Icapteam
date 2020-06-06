<#
.Synopsis
  Copying the latest release files from a shared folder to a remote deployment machine using PSSession

.Description
  Author: Avishai Gelberg avishai.gelberg@philips.com
  Last Updated: 05/06/2019

.Example 
  .\CopyNightlyRelease.ps1 -NightlyReleasePath "\\161.85.68.48\RnD\Builds\ICAP\Nightlies" -NightlyFolderName "ISP11_RC_SpectralCTApps_GATED"  `
						   -Code1User "code1user" -Code1Pass "code1pass" -RemoteServerAddress "1.1.1.1" -RemoteServerUser "rmtsrvusr"  `
						   -RemoteServerUser "rmtsrvusr" -RemoteServerPass "rmtsrvpass"
   
#>

Param (
    [Parameter(Mandatory=$true)] 
    [Alias("NightlyReleasesPath")] 
    [string]$NightlyReleasesPathString,

    [Parameter(Mandatory=$true)] 
    [Alias("NightlyFolderName")] 
    [string]$NightlyFolderNameString,
  
    [Parameter(Mandatory=$true)] 
    [Alias("Code1User")] 
    [string]$Code1UserString,

    [Parameter(Mandatory=$true)] 
    [Alias("Code1Pass")] 
    [string]$Code1PassString,
  
    [Parameter(Mandatory=$true)] 
    [Alias("RemoteServerAddress")] 
    [string]$RemoteServerAddressString,

    [Parameter(Mandatory=$true)] 
    [Alias("RemoteServerUser")] 
    [string]$RemoteServerUserString,

    [Parameter(Mandatory=$true)] 
    [Alias("RemoteServerPass")] 
    [string]$RemoteServerPassString
  ) #end params

# Initializing credentials for PSSession and PSDrive
$remoteSessionPassword = ConvertTo-SecureString $RemoteServerPassString -AsPlainText -Force
$remoteSessionCredential = New-Object System.Management.Automation.PSCredential ("$RemoteServerAddressString\$RemoteServerUserString", $remoteSessionPassword)

$remotePSDrivePassword = ConvertTo-SecureString $Code1PassString -AsPlainText -Force
$remotePSDriveCredential = New-Object System.Management.Automation.PSCredential ($Code1UserString, $remotePSDrivePassword)

Write-Output "Creating a new PSDrive with shared folder $NightlyReleasesPathString"
    Try {
        $psdriveSctipt = New-PSDrive -Name P -PSProvider FileSystem -Root $NightlyReleasesPathString -Credential $remotePSDriveCredential
        Write-Output "PSDrive created succefully"
            $productVersionPath = "$NightlyReleasesPathString\$NightlyFolderNameString\ProductVersion.txt"

            Write-Output "Reading content of $productVersionPath "
            Try {
                $latestReleaseFolder = Get-Content -Path $productVersionPath
                Write-Output "Content of $productVersionPath retrived successfully: $latestReleaseFolder"
                }

            Catch{
                Write-Output "Could not read content of $productVersionPath "
                Write-Output $_.Exception.Message
                }
    
                    Write-Output "Creating a new PSSession to $RemoteServerAddressString"
                    Try {
                        $targetSession = New-PSSession -ComputerName $RemoteServerAddressString -Credential $remoteSessionCredential
                        Write-Output "PSSession created successfully"
                        Write-Output $targetSession
                        }

                    Catch {
                        Write-Host "Could not create a PSSession to $RemoteServerAddressString"
                        Write-Output $_.Exception.Message
                        }

                        Write-Output "Copying '$NightlyReleasesPathString\$NightlyFolderNameString\$latestReleaseFolder' content to folder D:\NightlyBuildRelease on target machine $RemoteServerAddressString"
                        Try {
                             Invoke-command -Session $targetSession -ScriptBlock { Remove-Item -Path "D:\NightlyBuildRelease\*" -ErrorAction Ignore -Confirm:$false -Recurse -Force} 
                             Copy-Item -ToSession $targetSession -Path "$NightlyReleasesPathString\$NightlyFolderNameString\$latestReleaseFolder" -Destination "D:\NightlyBuildRelease"  -Force -Recurse -Verbose
                             Remove-PSDrive -Name P
                             Remove-PSSession -ComputerName $RemoteServerAddressString
                            }

                        Catch{
                            Write-Output "Could not copy from $NightlyReleasesPathString\$latestReleaseFolder\$latestReleaseFolder"
                            Write-Output $_.Exception.Message
                            Remove-PSDrive -Name P
                            Remove-PSSession -ComputerName $RemoteServerAddressString
                            }


        }
    Catch {
        Write-Output "Could not map a PSDrive!"
        Write-Output $_.Exception.Message
        }

