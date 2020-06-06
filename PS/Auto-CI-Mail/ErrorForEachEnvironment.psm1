Import-Module ".\GenerateErrorEnv.psm1"

function GetErrorForEachEnvironment{
    [CmdletBinding()] 
    param
    (
        [Parameter(Mandatory=$true)] 
        [Alias('All Release details')] 
        [System.Collections.ArrayList]$MailReleases,
        [Parameter(Mandatory=$true)] 
        [Alias('Credentials')] 
        $GetParameters,
        [Parameter(Mandatory=$true)] 
        [Alias('Definition status Mapping')] 
        [hashtable]$DefinitionNameMAping
    )
    $newLineChar = "`r`n`r`n"
    $linkReleaseRID = "https://tfsemea1.ta.philips.com/tfs/TPC_Region11/HIT_ISP/_apis/release/releases?releaseId="
    $user = $GetParameters.Credentials.User
    $SecurePassWord = ConvertTo-SecureString -AsPlainText  $GetParameters.Credentials.PassWord -Force
    $Cred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $user,$SecurePassWord
    foreach($MailRelease in $MailReleases)
    {   
        Write-Host "Looping"     
        $EnvUrl= $linkReleaseRID+$MailRelease.ReleaseRID
        $ReleaseJson = Invoke-RestMethod -Method 'Get' -Uri  $EnvUrl -Credential $Cred    
        Write-Host $MailRelease.ReleaseRID

        $totalEnvironments = $ReleaseJson.environments.Count
        $MailRelease.ServerDeploy = $ReleaseJson.environments[0].status
        Write-Host $MailRelease.ServerDeploy+"-"+ $MailRelease.ReleaseRID        
        if($MailRelease.ServerDeploy.Equals("rejected") )
        {
            $MailRelease.ServerError = GenerateError -EnvDetail $ReleaseJson.environments[0]
        }

        $startEnvCount =1
        if($GetParameters.Credentials.Project -ne "ISP11")
        {
            try
            {
                    $MailRelease.ClientDeploy = $ReleaseJson.environments[1].status
                    Write-Host $MailRelease.ClientDeploy+"-"+ $MailRelease.ReleaseRID
                    if($MailRelease.ClientDeploy.Equals("rejected") -and $MailRelease.ClientDeploy)
                    {
                        $MailRelease.ClientError = GenerateError -EnvDetail $ReleaseJson.environments[1]
                    }
            }
            catch
            {
                Write-Host "Client Deployment not found"
            }

            $startEnvCount =2
        }
        
        for([int]$i=$startEnvCount;$i -lt $totalEnvironments-1 ;$i++)
        {
            if($DefinitionNameMAping[$ReleaseJson.environments[$i].status].Equals("Failed") -or $DefinitionNameMAping[$ReleaseJson.environments[$i].status].Equals("NA"))
            {
                $MailRelease.SanityTest = "failed"
                break
            }
            elseif($DefinitionNameMAping[$ReleaseJson.environments[$i].status].Equals("In Progress"))
            {
                $MailRelease.SanityTest = "inProgress"
            }
            elseif($DefinitionNameMAping[$ReleaseJson.environments[$i].status].Equals("Not Started"))
            {
                $MailRelease.SanityTest = "notStarted"
            }
            elseif($MailRelease.SanityTest -ne "inProgress" -and $MailRelease.SanityTest -ne "notSatrted")
            {
                $MailRelease.SanityTest = "succeeded"
            }
        }
        $MailRelease.Promotion = $ReleaseJson.environments[$totalEnvironments-1].status
    }
    return $MailReleases
}

