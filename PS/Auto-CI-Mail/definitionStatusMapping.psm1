

function DeifnitionMapping{
    [CmdletBinding()] 
    param
    (
        [Parameter(Mandatory=$true)] 
        [Alias('Credentials')] 
        $GetParameters
    )
    $DefinitionNameMAping = @{}
    $statusCount =$GetParameters.Credentials.StatusCount
    $applicationCount=$GetParameters.Credentials.ApplicationCount
    for([int]$i=0;$i -lt ([int]$applicationCount+[int]$statusCount);$i++)
    {
        if($i -ge $applicationCount)
        {
            $DefinitionNameMAping[$GetParameters.StatusObtained[$i - [int]$applicationCount]]=$GetParameters.StatusActual[$i - [int]$applicationCount]
        }
        else
        {
            if($GetParameters.BuildNames[$i] -eq "ViewingInfra" -and $GetParameters.Credentials.Project -eq "ISP11" )
            {
                $DefinitionNameMAping[$GetParameters.Credentials.Project+$GetParameters.Credentials.Connector1+$GetParameters.Credentials.BranchName+$GetParameters.Credentials.Connector1+$GetParameters.BuildNames[$i]]=$GetParameters.ApplicationName[$i]
            }
            else
            {
                $DefinitionNameMAping[$GetParameters.Credentials.Project+$GetParameters.Credentials.Connector1+$GetParameters.Credentials.BranchName+$GetParameters.Credentials.Connector2+$GetParameters.BuildNames[$i]]=$GetParameters.ApplicationName[$i]
            }
        }
    }
    return $DefinitionNameMAping
}

