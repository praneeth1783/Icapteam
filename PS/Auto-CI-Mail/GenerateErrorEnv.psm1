function GenerateError{
    [CmdletBinding()] 
    param
    (
        [Parameter(Mandatory=$true)] 
        [Alias('Environmnet Detail')] 
        $EnvDetail
    )
    $ErrorMessage = ""
    $DeployStepsCount = $EnvDetail.deploySteps.Count
    Write-Host "Deploy steps : $($DeployStepsCount)"
    $deploysteps = $EnvDetail.deploySteps
    for([int]$i=0;$i -lt $DeployStepsCount ; $i++)
    {
        Write-Host "Deploy step : $($i)"
        $CountDeployPhases = $deploysteps[$i].releaseDeployPhases.Count
        Write-Host "Deploy phases : $($CountDeployPhases)"
        $DeployPhases = $deploysteps[$i].releaseDeployPhases
        for([int]$j=0;$j -lt $CountDeployPhases ;$j++)
        {
            $CountDeploymentJobs = $DeployPhases[$j].deploymentJobs.Count
            Write-Host "Deployment Jobs: $($CountDeploymentJobs)"
            Write-Host "Deployment Phase: $($j)"
            $DeploymentJobs = $DeployPhases[$j].deploymentJobs
            for([int]$k=0 ; $k -lt $CountDeploymentJobs ; $k++)
            {
                $countTasks = $DeploymentJobs[$k].tasks.Count
                $Tasks = $DeploymentJobs[0].tasks
                Write-Host $Tasks
                Write-Host "Tasks: $($countTasks)"
                Write-Host "Deployment Job: $($k)"
                if($Tasks)
                {
                    for([int]$l=0 ; $l -lt $countTasks ; $l++)
                    {
                        Write-Host "Task: $($l)"
                        if($Tasks[$l])
                        {
                            $NumIssues = $Tasks[$l].issues.Count
                            $Issue = $Tasks[$l].issues
                            for([int]$p=0;$p -lt $NumIssues ; $p++)
                            {
                                if($Issue[$p].issueType -eq "Error")
                                {
                                    $tempMessageAppendClient = $Issue[$p].message+ $newLineChar
                                    $ErrorMessage += $tempMessageAppendClient 
                                    Write-Host $Issue[$p].message
                                }
                            }
                        }                           
                    }
                }
                    
            }
        }
    }
    return $ErrorMessage
}

