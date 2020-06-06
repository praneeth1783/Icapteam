

function ReleaseMapping{
    [CmdletBinding()] 
    param
    (
        [Parameter(Mandatory=$true)] 
        [Alias('Credentials')] 
        $GetParameters
    )
    $ReleaseNameMapping = @{}

    if($GetParameters.Credentials.Project -eq "ISP11")
    {
        for([int]$i=0;$i -lt $GetParameters.Credentials.ApplicationCount ; $i++)
        {
            if($GetParameters.ReleaseNames[$i] -eq "SpectralCTApps_Release")
            {
                $ReleaseNameMapping[$GetParameters.Credentials.Project+"_"+$GetParameters.Credentials.BranchName+"_"+$GetParameters.ReleaseNames[$i]]=$GetParameters.ApplicationName[$i]
            }
            else
            {
                $ReleaseNameMapping[$GetParameters.Credentials.Project+"_"+$GetParameters.ReleaseNames[$i]]=$GetParameters.ApplicationName[$i]
            }
        }
    }
    else
    {
        for([int]$i=0;$i -lt  $GetParameters.Credentials.ApplicationCount ; $i++)
        {
            $ReleaseNameMapping[$GetParameters.Credentials.Project+"_"+$GetParameters.Credentials.BranchName+"_"+$GetParameters.ReleaseNames[$i]]=$GetParameters.ApplicationName[$i]
        }
    }
    
    return $ReleaseNameMapping
}

