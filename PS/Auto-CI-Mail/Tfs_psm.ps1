$StartTime = (Get-Date)
#Fetching all JSON file list
 $DirAll = Get-ChildItem -Recurse
 $ListJson = $DirAll |where {$_.Extension -eq ".json"}
 $numfiles = $ListJson.Length
 $CurrentPath = Get-Location
 #[Net.ServicePointManager]::SecurityProtocol += [Net.SecurityProtocolType]::Tls12
 for([int]$p=0 ; $p -lt $numfiles ;$p++)
 {
    #$p=1

        #Contains parameters for Login and Folder Path
        $fileName =  $ListJson.GetValue($p).Name
        Import-Module "$CurrentPath\credentials.psm1"

        $GetParameters = GetCredentials -FileName $fileName
        $DropPath = $GetParameters.Credentials.DropPath
        $dateToday = (Get-Date).GetDateTimeFormats("d")[-1]

        #a temp arraylist to hold the output in the end
        $DesiredBuilds=New-Object System.Collections.ArrayList

        Import-Module "$CurrentPath\GetBuilds.psm1"

        $builds = GetBuilds -GetParameters $GetParameters

        #Loop through all the builds and filter it using the times
        foreach($build in $builds)
        {
            if($build.definition.name.Contains($GetParameters.Credentials.Project) -and $build.definition.name.Contains($GetParameters.Credentials.BranchName)  -and !$build.definition.name.EndsWith("clone"))
            {   
                Write-Host "Including the build $($build.definition.name) triggered on $($QueueTime) to the report"
    
                $Detailsuri= "https://tfsemea1.ta.philips.com/tfs/TPC_Region11/HIT_ISP/_apis/build/builds/$($build.id)"

                if($build.finishTime)
                {
                    $finishTime = [datetime]$build.finishTime
                }
                else
                {
                    $finishTime = ""
                }

                #Create a new object with only the details we need
                $BuildObject = [PSCustomObject]@{
                        "BuildDefinition" = $build.definition.name.Trim()
                        "BuildNumber" = $build.buildNumber
                        "BuildID" = $build.id
                        "IsNightly"= $build.definition.path.Contains("Nightly") -or $build.queue.name.Contains("Nightly")
                        "RrequestedBy" = $build.requestedBy.displayName
                        "Status" = $build.status
                        "Result" = $build.result
                        "ErrorMessage"=$build.logs.url
                        "SourceBranch" = $build.sourceBranch
                        "QueueTime" = [datetime]$build.queueTime
                        "FinishTime" = $finishTime
                        } 

                #Add the builds with details to arraylist
                $DesiredBuilds +=$BuildObject
            }   

        }



        $DesiredBuilds | Export-Csv -Path "$DropPath\HIT_ISP_DBuilds1_$dateToday.csv" -NoTypeInformation

        #Temporary arraylist 
        $MailBuilds=New-Object System.Collections.ArrayList

        Import-Module "$CurrentPath\definitionStatusMapping.psm1"
        $DefinitionNameMAping=DeifnitionMapping -GetParameters $GetParameters

        Import-Module "$CurrentPath\releasseMapping.psm1"
        $ReleaseNameMapping=ReleaseMapping -GetParameters $GetParameters

        Import-Module "$CurrentPath\SanityLogMapping.psm1"
        $SanityTestUrl=SanityMapping -GetParameters $GetParameters

        #fetching latest builds from $DesiredBuiilds object

        foreach($desiredBuild in $DesiredBuilds)
        {
            if($DefinitionNameMAping[$desiredBuild.BuildDefinition] -ne $null)
            {
                $ShouldIncludeBuild = $true
            }
            else
            {
                $ShouldIncludeBuild = $false
            }

            if(($desiredBuild.QueueTime.Date -eq $dateToday) -or ($desiredBuild.QueueTime.Date -eq (Get-Date).AddDays(-1).GetDateTimeFormats("d")[-1]) -and ($desiredBuild.IsNightly)  -and $ShouldIncludeBuild)
            {
                Write-Host "Including the build $($desiredBuild.BuildDefinition) triggered on $QueueTime to the report1"
                $MailBuildsObject = [PSCustomObject]@{
                "MailBuildId" = $desiredBuild.BuildID
                "MailReleaseRID"=""
                "MailReleaseId" = "NA"
                "MailBuildDefinition"=$DefinitionNameMAping[$desiredBuild.BuildDefinition]
                "MailBuildStatus" = $desiredBuild.Status
                "MailBuildResult" = $desiredBuild.Result
                "MailQueueTime"= $desiredBuild.QueueTime
                "MailFinishTime"=$desiredBuild.FinishTime
                "MailErrorMessage"=$desiredBuild.ErrorMessage
                "MailServerDeploy" = "NA"
                "MailServerErrorMessage"=""
                "MailClientErrorMessage"=""
                "MailClientDeploy"="NA"
                "MailSanityTest"="NA"
                "MailPromotion"="NA"
                "IsAssigned"= $false
                "IsNightly" = $desiredBuild.IsNightly
                "ShouldInclude"= $true
                "MailReleaseStatus" = "NA"
                }
                $MailBuilds+= $MailBuildsObject
            }    
        }



        $length = $MailBuilds.Length

        #Decide Whether to include a build or not

        for([int]$i=0 ; $i -lt $length ;$i++)
        {
            $TempBuildName = $MailBuilds.Get($i).MailBuildDefinition
            $TempBuildID = $MailBuilds.Get($i).MailBuildID
            for([int]$j=$i+1; $j -lt $length ; $j++)
            {
                if($MailBuilds.Get($j).ShouldInclude -and $TempBuildName.Equals($MailBuilds.Get($j).MailBuildDefinition) -and $TempBuildID -lt $MailBuilds.Get($j).MailBuildID)
                {
                    $MailBuilds.Get($i).ShouldInclude = $false
                    break
                }
                elseif($MailBuilds.Get($j).ShouldInclude -and $TempBuildName.Equals($MailBuilds.Get($j).MailBuildDefinition) -and $TempBuildID -gt $MailBuilds.Get($j).MailBuildID)
                {
                    $MailBuilds.Get($j).ShouldInclude = $false
                }
            }
        }

        #Checking if all builds passed or not

        $includedBuildCount = 0
        $TotalMailedBuildCount =0

        foreach($Mailbuild in $MailBuilds)
        {
            if($Mailbuild.MailBuildStatus -eq "completed" -and $Mailbuild.MailBuildResult.ToString() -eq "succeeded" -and $Mailbuild.ShouldInclude)
            {
                $includedBuildCount = $includedBuildCount+1
            }
            if($Mailbuild.ShouldInclude)
            {
                $TotalMailedBuildCount = $TotalMailedBuildCount+1
            }
        }

        Import-Module "$CurrentPath\GetGreenCI.psm1"
        GetGreenCIStatus -TotalMailedBuildCount $TotalMailedBuildCount -includedBuildCount $includedBuildCount

        Write-Host "Green CI status Checked"

        Import-Module "$CurrentPath\GetBuildError.psm1"
         Write-Host "Build Definition name updated"
        foreach($MailBuild in $MailBuilds)
        {           
            if($MailBuild.MailBuildStatus -eq "completed" -and $MailBuild.MailBuildResult -eq "failed" -and $MailBuild.MailQueueTime -ge [DateTime]::Today.AddDays(-1).AddHours(18) -and $Mailbuild.ShouldInclude) 
            {
                $user = $GetParameters.Credentials.User
                $SecurePassWord = ConvertTo-SecureString -AsPlainText  $GetParameters.Credentials.PassWord -Force
                $Cred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $user,$SecurePassWord
                try
                {
                    $errorJson = Invoke-WebRequest -Method 'Get' -Uri  $MailBuild.MailErrorMessage -Credential $Cred -ErrorAction SilentlyContinue
                }
                catch
                {
                    Write-Host "Invoking is not working"
                }
                [int]$i=0
                $isErrorFetched = $false
                do
                {    
                    if($isErrorFetched -eq $true)
                    {
                        break
                    } 
                    
                    if($i -gt $GetParameters.Matching.Count )
                    {
                        $FetchErrorContent="Build Stopped or Cancelled"
                        break
                    } 

                    $i = $i+1   

                    
                   
                    $FetchErrorContent = GetBuildError -errorJson $errorJson -Match $GetParameters.Matching[$i-1].Match -split $GetParameters.Matching[$i-1].Split
                    Write-Host "Fetched Error is $($FetchErrorContent)"
                    if($FetchErrorContent -ne "NA")
                    {
                        $isErrorFetched = $true
                    }

                }While($FetchErrorContent -eq "NA" -or  $i -ne $GetParameters.Matching.Count)
        
                $MailBuild.MailErrorMessage = $FetchErrorContent
                Write-Host $MailBuild.MailErrorMessage        
            
            }
                 
            elseif($MailBuild.MailBuildResult -eq 'partiallySucceeded' -or $MailBuild.MailBuildResult -eq 'succeeded' -or $MailBuild.MailBuildStatus -eq 'inProgress' -or $MailBuild.MailBuildResult -eq 'canceled')
            {
                $MailBuild.MailErrorMessage = ""
            }
            Write-Host "Error Message generated for BuildId $($MailBuild.MailBuildId)"
        }
        Write-Host "Error Message Updated"

        $MailBuilds | Export-Csv -Path "$DropPath\HIT_ISP_Builds1_$dateToday.csv" -NoTypeInformation

        #Geting Release Object

        Write-Host "Getting Release Detail"

        $MailReleases=New-Object System.Collections.ArrayList

        Import-Module "$CurrentPath\GetReleases.psm1"

        $releases = GetReleases -GetParameters $GetParameters

        if($GetParameters.Credentials.Project -eq "ISP11")
        {
            foreach($release in $releases.value)
            {
                $MailreleaseObject = [PSCustomObject]@{
                "ReleaseRID"=$release.id
                "ReleasID"= $release.releaseDefinition.id
                "ReleaseName"= $release.releaseDefinition.name.Trim()
                "ReleaseStatus"=$release.status
                "ReleaseTime"=[datetime]$release.modifiedOn 
                "ServerDeploy" = "NA"
                "ServerError"=""
                "SanityTest"="NA"
                "Promotion"="NA"
                "IsRequired"= $true 
                }
                $MailReleases += $MailreleaseObject
            }    
        }
        else
        {
            foreach($release in $releases.value)
            {
                $MailreleaseObject = [PSCustomObject]@{
                "ReleaseRID"=$release.id
                "ReleasID"= $release.releaseDefinition.id
                "ReleaseName"= $release.releaseDefinition.name.Trim()
                "ReleaseStatus"=$release.status
                "ReleaseTime"=[datetime]$release.modifiedOn 
                "ServerDeploy" = "NA"
                "ServerError"=""
                "ClientDeploy"="NA"
                "ClientError"=""
                "SanityTest"="NA"
                "Promotion"="NA"
                "IsRequired"= $true 
                }
                $MailReleases += $MailreleaseObject
            }
        }


        #Getting only required Releases

        foreach($MailRelease in $MailReleases)
        {
            $MailRelease.IsRequired = ($MailRelease.ReleaseTime.Date -eq $dateToday -or $MailRelease.ReleaseTime -ge [DateTime]::Today.AddDays(-1).AddHours(21) ) -and ($MailRelease.ReleaseName -ne $null)
            Write-Host "For Release$($MailRelease.ReleaseName)Releasename"
            $MailRelease.ReleaseName = $ReleaseNameMapping[$MailRelease.ReleaseName]
            Write-Host $MailRelease.ReleaseName
        }

        $MailReleases | Export-Csv -Path "$DropPath\HIT_ISP_Releasews1_$dateToday.csv" -NoTypeInformation

        #Getting Release status for each environment

        Import-Module "$CurrentPath\ErrorForEachEnvironment.psm1"

        $MailReleases = GetErrorForEachEnvironment -MailReleases $MailReleases -GetParameters $GetParameters -DefinitionNameMAping $DefinitionNameMAping

        if($GetParameters.Credentials.Project -eq "ISP11")
        {
            foreach($Mailbuild in $MailBuilds  )
            {
                if($Mailbuild.ShouldInclude )
                {
                    $TempObject = $MailReleases.GetEnumerator()
                    while($TempObject.MoveNext())
                    {
                       if($TempObject.current.ReleaseName -eq $Mailbuild.MailBuildDefinition -and $TempObject.current.IsRequired -and $Mailbuild.IsAssigned -eq $false )
                       {
                            $Mailbuild.MailReleaseId = $TempObject.current.ReleasID
                            $Mailbuild.MailReleaseRID = $TempObject.Current.ReleaseRID
                            $Mailbuild.MailReleaseStatus = $TempObject.current.ReleaseStatus
                            $Mailbuild.MailPromotion = $TempObject.Current.Promotion
                            $Mailbuild.MailSanityTest = $TempObject.Current.SanityTest
                            $Mailbuild.MailServerDeploy = $TempObject.Current.ServerDeploy
                            $Mailbuild.MailServerErrorMessage = $TempObject.Current.ServerError
                            $Mailbuild.IsAssigned = $true
                       }
                    }        
                }
            }
        }
        else
        {
            foreach($Mailbuild in $MailBuilds  )
            {
                if($Mailbuild.ShouldInclude )
                {
                    $TempObject = $MailReleases.GetEnumerator()
                    while($TempObject.MoveNext())
                    {
                       if($TempObject.current.ReleaseName -eq $Mailbuild.MailBuildDefinition -and $TempObject.current.IsRequired -and $Mailbuild.IsAssigned -eq $false -and $TempObject.Current.ReleaseTime -ge $MailBuild.MailQueueTime)
                       {
                            $Mailbuild.MailReleaseId = $TempObject.current.ReleasID
                            $Mailbuild.MailReleaseRID = $TempObject.Current.ReleaseRID
                            $Mailbuild.MailReleaseStatus = $TempObject.current.ReleaseStatus
                            $Mailbuild.MailClientDeploy = $TempObject.Current.ClientDeploy
                            $MailBuild.MailClientErrorMessage = $TempObject.Current.ClientError
                            $Mailbuild.MailPromotion = $TempObject.Current.Promotion
                            $Mailbuild.MailSanityTest = $TempObject.Current.SanityTest
                            $Mailbuild.MailServerDeploy = $TempObject.Current.ServerDeploy
                            $Mailbuild.MailServerErrorMessage = $TempObject.Current.ServerError
                            $Mailbuild.IsAssigned = $true
                       }
                    }        
                }
            }
        }



        Write-Host "Release ID Assigned"

        $Maillength = $MailReleases.Length

        $MailBuilds | Export-Csv -Path "$DropPath\HIT_ISP_Builds_$dateToday.csv" -NoTypeInformation

        $MailReleases | Export-Csv -Path "$DropPath\HIT_ISP_Releasews_$dateToday.csv" -NoTypeInformation

        if(Test-Path -Path "$DropPath\HIT_ISP_GreenCI.json")
        {
            $GetGreenCI = Get-Content "$DropPath\HIT_ISP_GreenCI.json" | Out-String | ConvertFrom-Json
            $GreenCIObject = New-Object -TypeName PSObject
            $GreenCIObject | Add-Member -MemberType NoteProperty -Name Title -Value $GetGreenCI.Title
            $GreenCIObject | Add-Member -MemberType NoteProperty -Name LastGreenCIDate -Value $GetGreenCI.LastGreenCIDate
            $CIcolor = "#CD5C5C"

            if($GetGreenCI -ne "" -and $GreenCIObject.LastGreenCIDate -eq $dateToday)
            {
                $CIcolor = "#98FB98"
            }
        }
        else
        {
            $CIcolor = "#CD5C5C"
        }

        # Designing E-Mail template
        Write-Host "Sending Mail"

        Import-Module "$CurrentPath\SendMail.psm1"

        $SendMailObject = SendMail -MailBuilds $MailBuilds -GetParameters $GetParameters -DefinitionNameMAping $DefinitionNameMAping -ReleaseNameMapping $ReleaseNameMapping -SanityTestUrl $SanityTestUrl

        try
        {
            #Send-MailMessage -From noreply@philips.com -Subject "ISP12 Nightly Build Daily Continuous Integration Status Automation report $($dayToday)" -To DL_ICAP_DevOps@philips.com -Body $body -BodyAsHtml -Cc parth.vs@philips.com -Port 25 -SmtpServer smtprelay-nam1.philips.com

            Send-MailMessage -From $SendMailObject.MailFrom -Subject $SendMailObject.MailSubject -To $SendMailObject.MailTo -Body $SendMailObject.MailBody -BodyAsHtml -Port $SendMailObject.MailPort  -SmtpServer $SendMailObject.MailSMTP
        }
        catch
        {

            Write-Host "Error sending mail $_"

        }

        Write-Host "Mail Sent"

        $EndDate = (Get-Date)

        Write-Host "StartTime: $($StartTime) EndTime: $($EndDate)"
    
 }

