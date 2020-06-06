function SendMail{
    [CmdletBinding()] 
    param
    (
        [Parameter(Mandatory=$true)] 
        [Alias('All final build details')] 
        [System.Collections.ArrayList]$MailBuilds,
        [Parameter(Mandatory=$true)] 
        [Alias('Credentials')] 
        $GetParameters,
        [Parameter(Mandatory=$true)] 
        [Alias('Definition status Mapping')] 
        [hashtable]$DefinitionNameMAping,
        [Parameter(Mandatory=$true)] 
        [Alias('Release application mapping')] 
        [hashtable]$ReleaseNameMapping,
        [Parameter(Mandatory=$true)] 
        [Alias('Sanitylog Mapping')] 
        [hashtable]$SanityTestUrl

    )
    $link = "https://tfsemea1.ta.philips.com/tfs/TPC_Region11/HIT_ISP/_build/index?buildId="
    $linkRelease = "https://tfsemea1.ta.philips.com/tfs/TPC_Region11/HIT_ISP/_release?definitionId="
    $appendString = "&releaseId="
    $link_ISP12 = "https://tfsemea1.ta.philips.com/tfs/TPC_Region11/HIT_ISP/_dashboards?activeDashboardId=49e8158d-6a45-41fe-a0ff-575b6b24278e"
    $link_ISP11 = "https://tfsemea1.ta.philips.com/tfs/TPC_Region11/HIT_ISP/_dashboards?activeDashboardId=4fe42a6e-7d43-4e40-aa97-57451de5d59d"
    if($GetParameters.Credentials.Project -eq "ISP12")
    {
        $dashBoardLink = $link_ISP12
    }
    elseif($GetParameters.Credentials.Project -eq "ISP11")
    {
        $dashBoardLink = $link_ISP11
    }

    $smtp ="ilqhfaatc1msmtp"
    $to =  "<parth.vs@philips.com>"
    #$to = @("<parth.vs@philips.com>";"<Rakesh.C@philips.com>","<Manjunath.HA@philips.com>","<sruthy.as@philips.com>","<preethi.g@philips.com>","<kiran.b@philips.com>";"arik.amir@philips.com";"chaithra.m@philips.com";"avishai.gelberg@philips.com";"kishan.harwalkar@philips.com";"shai.ovadia@philips.com";"Balvinder.Yadav@philips.com";"amir.yavin@philips.com";"kavya.yk@philips.com")

    #$to = @("<parth.vs@philips.com>";"<Rakesh.C@philips.com>","<Manjunath.HA@philips.com>","<sruthy.as@philips.com>","<preethi.g@philips.com>","<kiran.b@philips.com>")

    $from = "noreplay-DevOps@philips.com"

    $subject = $GetParameters.Credentials.Project+" "+$GetParameters.Credentials.BranchName+" Daily Continuous Integration Status Automation report $dateToday"

    $body = "<H2>"+$GetParameters.Credentials.Project +" "+$GetParameters.Credentials.BranchName+"</H2>"

    $body += "<b><font color=black>$dateToday Daily Continuous Integration Status Automation report</b></font> <br><br>"

    $body+= "This report is based on <a href="+$dashBoardLink+">Dashboard</a><br><br>"

    $body+= "<table style='border:3px solid black;border-collapse:collapse;'>"

    #$body += "<th></th><th></th>"

    $body+= "<tr ><td bgcolor='gray' style='border:3px solid black;'>Overall CI status</td><td bgcolor=$CIcolor style='border:3px solid black;'> Last Green CI Passed on -"+$GreenCIObject.LastGreenCIDate+"</td></tr>"

    $body+= "</table><br><br>"

    $body+= "<table style='border:3px solid black;border-collapse:collapse;'>"

    #$body += "<th ></th><th></th>"

    $body+= "<tr bgcolor='#98FB98'><td>Build Pass Succeeded Today</td><td></td><td></td></tr>"

    $body+= "<tr bgcolor='#FFDAB9'><td>Build Partially Passed Today</td><td></td><td></td></tr>"

    $body+= "<tr bgcolor='#CD5C5C'><td>Build Failed Today</td><td></td><td></td></tr>"

    $body+= "</table>"

    $body+="<br><br>"

    $body += "<table style='border:3px solid black;border-collapse:collapse;'>"

    $body += "<tr bgcolor='gray'style='border:3px solid black;' >" 

    if($GetParameters.Credentials.Project -eq "ISP11")
    {
        $body += "<th style='border:3px solid black;'>CI Pipeline</th><th style='border:3px solid black;'>Build Status</th><th style='border:3px solid black;'>Build Error Message</th>"

        $body += "<th style='border:3px solid black;'>Server/Client Deploy</th><th style='border:3px solid black;'>Server/Client Deploy ErrorMessage</th>"

        $body +="<th style='border:3px solid black;'>Sanity Test</th><th style='border:3px solid black;'>Sanity Log</th><th style='border:3px solid black;'>Promotion</th>"

        $body += "<th style='border:3px solid black;'>Overall Release Status</th>"

        $body += "</tr>"
        foreach($MailBuild in $MailBuilds)
        {
	        if($MailBuild.ShouldInclude)
	        {
        
                $promotionColor = "White"
                $ServerColor = "White"
                $clientColor = "White"
                $SanityColor = "White"
                $buildColor = "white"

                if($DefinitionNameMAping[$MailBuild.MailBuildStatus].Equals("Completed"))
                {
                    if($DefinitionNameMAping[$MailBuild.MailBuildResult].Equals("Succeeded"))
		            {
			            $buildColor = "#98FB98"
			            $linkColor = "black"
		            }
        
                    elseif($DefinitionNameMAping[$MailBuild.MailBuildResult].Equals("Partially Succeeded"))
		            {
			            $buildColor = "#FFDAB9"
			            $linkColor = "blue"
		            }

		            elseif($DefinitionNameMAping[$MailBuild.MailBuildResult].Equals("Failed"))
                    {
                        $buildColor = "#CD5C5C"
			            $linkColor = "cyan"
                        $MailBuild.MailClientDeploy = "notStarted"
                        $MailBuild.MailClientErrorMessage=""
                        $MailBuild.MailPromotion = "notStarted"
                        $MailBuild.MailReleaseId =""
                        $MailBuild.MailReleaseRID=""
                        $MailBuild.MailSanityTest="notStarted"
                        $MailBuild.MailReleaseStatus="notstarted"
                        $MailBuild.MailSanityTest="notStarted"
                        $MailBuild.MailServerDeploy="notStarted"
                        $MailBuild.MailServerErrorMessage=""
                    }
                }

                elseif($DefinitionNameMAping[$MailBuild.MailBuildStatus].Equals("In Progress"))
                {
                    $MailBuild.MailBuildResult = "inProgress"
                    $buildColor = "#FFDAB9"
			        $linkColor = "blue"
                    $MailBuild.MailClientDeploy = "notStarted"
                    $MailBuild.MailClientErrorMessage=""
                    $MailBuild.MailPromotion = "notStarted"
                    $MailBuild.MailReleaseId =""
                    $MailBuild.MailReleaseRID=""
                    $MailBuild.MailSanityTest="notStarted"
                    $MailBuild.MailReleaseStatus="notstarted"
                    $MailBuild.MailSanityTest="notStarted"
                    $MailBuild.MailServerDeploy="notStarted"
                    $MailBuild.MailServerErrorMessage=""
                }	
                elseif($DefinitionNameMAping[$MailBuild.MailBuildStatus].Equals("Not Started"))
                {
                    $MailBuild.MailBuildResult = "notStarted"
                    $MailBuild.MailErrorMessage = ""
                    $buildColor = "#CD5C5C"
			        $linkColor = "cyan"
                }	
		

                if($DefinitionNameMAping[$MailBuild.MailServerDeploy].Equals("Succeeded"))
		        {
			        $ServerColor = "#98FB98"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailServerDeploy].Equals("In Progress") -or $DefinitionNameMAping[$MailBuild.MailServerDeploy].Equals("Partially Succeeded"))
		        {
			        $ServerColor = "#FFDAB9"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailServerDeploy].Equals("Failed")  -or $DefinitionNameMAping[$MailBuild.MailServerDeploy].Equals("Not Started") )
		        {
			        $ServerColor = "#CD5C5C"
		        }


                if($DefinitionNameMAping[$MailBuild.MailSanityTest].Equals("Succeeded"))
		        {
			        $SanityColor = "#98FB98"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailSanityTest].Equals("In Progress") -or $DefinitionNameMAping[$MailBuild.MailServerDeploy].Equals("Partially Succeeded"))
		        {
			        $SanityColor = "#FFDAB9"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailSanityTest].Equals("Failed")  -or $DefinitionNameMAping[$MailBuild.MailSanityTest].Equals("Not Started") )
		        {
			        $SanityColor = "#CD5C5C"
		        }

		        if($DefinitionNameMAping[$MailBuild.MailPromotion].Equals("Succeeded"))
		        {
			        $promotionColor = "#98FB98"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailPromotion].Equals("In Progress") -or $DefinitionNameMAping[$MailBuild.MailServerDeploy].Equals("Partially Succeeded"))
		        {
			        $promotionColor = "#FFDAB9"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailPromotion].Equals("Failed")  -or $DefinitionNameMAping[$MailBuild.MailPromotion].Equals("Not Started") )
		        {
			        $promotionColor = "#CD5C5C"
		        }
		
		
		        $body += "<tr style='border:3px solid black;' >" 

                $body += "<td style='border:3px solid black;' align='center'>"+$MailBuild.MailBuildDefinition+"</td><td bgcolor=$buildColor style='border:3px solid black;'  align='center'><a href="+$link+$MailBuild.MailBuildId+" style='color:$linkColor'>"+$DefinitionNameMAping[$MailBuild.MailBuildResult]+"</a></td><td style='border:3px solid black;' align='center'>"+$MailBuild.MailErrorMessage+"</td>"

                $body += "<td bgcolor=$ServerColor style='border:3px solid black;' align='center'>"+$DefinitionNameMAping[$MailBuild.MailServerDeploy]+"</td><td style='border:3px solid black;' align='center'>"+$MailBuild.MailServerErrorMessage+"</td>" 
        
                $body += "<td bgcolor=$SanityColor style='border:3px solid black;' align='center'>"+$DefinitionNameMAping[$MailBuild.MailSanityTest]+"</td><td  style='border:3px solid black;' align='center'>"+$SanityTestUrl[$MailBuild.MailBuildDefinition]+"</td><td bgcolor=$promotionColor style='border:3px solid black;' align='center'>"+$DefinitionNameMAping[$MailBuild.MailPromotion]+"</td>"

                $body += "<td style='border:3px solid black;' align='center'><a href="+$linkRelease+$MailBuild.MailReleaseId+$appendString+$MailBuild.MailReleaseRID+">"+$DefinitionNameMAping[$MailBuild.MailReleaseStatus]+"</a></td>"

                $body += "</tr>"
                $promotionColor = "White"
                $ServerColor = "White"
                $clientColor = "White"
                $SanityColor = "White"
                $buildColor = "white"
	        }
        }

    }

    else
    {  

        $body += "<th style='border:3px solid black;'>CI Pipeline</th><th style='border:3px solid black;'>Build Status</th><th style='border:3px solid black;'>Build Error Message</th>"

        $body += "<th style='border:3px solid black;'>Server Deploy</th><th style='border:3px solid black;'>ServerDeploy ErrorMessage</th><th style='border:3px solid black;'>Client Deploy</th>"

        $body +="<th style='border:3px solid black;'>Client Deploy ErrorMessage</th><th style='border:3px solid black;'>Sanity Test</th><th style='border:3px solid black;'>Sanity Log</th><th style='border:3px solid black;'>Promotion</th>"

        $body += "<th style='border:3px solid black;'>Overall Release Status</th>"

        $body += "</tr>"
        foreach($MailBuild in $MailBuilds)
        {
	        if($MailBuild.ShouldInclude)
	        {
        
                $promotionColor = "White"
                $ServerColor = "White"
                $clientColor = "White"
                $SanityColor = "White"
                $buildColor = "white"

                if($DefinitionNameMAping[$MailBuild.MailBuildStatus].Equals("Completed"))
                {
                    if($DefinitionNameMAping[$MailBuild.MailBuildResult].Equals("Succeeded"))
		            {
			            $buildColor = "#98FB98"
			            $linkColor = "black"
		            }
        
                    elseif($DefinitionNameMAping[$MailBuild.MailBuildResult].Equals("Partially Succeeded"))
		            {
			            $buildColor = "#FFDAB9"
			            $linkColor = "blue"
		            }

		            elseif($DefinitionNameMAping[$MailBuild.MailBuildResult].Equals("Failed"))
                    {
                        $buildColor = "#CD5C5C"
			            $linkColor = "cyan"
                        $MailBuild.MailClientDeploy = "notStarted"
                        $MailBuild.MailClientErrorMessage=""
                        $MailBuild.MailPromotion = "notStarted"
                        $MailBuild.MailReleaseId =""
                        $MailBuild.MailReleaseRID=""
                        $MailBuild.MailSanityTest="notStarted"
                        $MailBuild.MailReleaseStatus="notstarted"
                        $MailBuild.MailSanityTest="notStarted"
                        $MailBuild.MailServerDeploy="notStarted"
                        $MailBuild.MailServerErrorMessage=""
                    }
                }

                elseif($DefinitionNameMAping[$MailBuild.MailBuildStatus].Equals("In Progress"))
                {
                    $MailBuild.MailBuildResult = "inProgress"
                    $buildColor = "#FFDAB9"
			        $linkColor = "blue"
                    $MailBuild.MailClientDeploy = "notStarted"
                    $MailBuild.MailClientErrorMessage=""
                    $MailBuild.MailPromotion = "notStarted"
                    $MailBuild.MailReleaseId =""
                    $MailBuild.MailReleaseRID=""
                    $MailBuild.MailSanityTest="notStarted"
                    $MailBuild.MailReleaseStatus="notstarted"
                    $MailBuild.MailSanityTest="notStarted"
                    $MailBuild.MailServerDeploy="notStarted"
                    $MailBuild.MailServerErrorMessage=""
                }	

		        elseif($DefinitionNameMAping[$MailBuild.MailBuildStatus].Equals("Not Started"))
                {
                    $MailBuild.MailBuildResult = "notStarted"
                    $MailBuild.MailErrorMessage = ""
                    $buildColor = "#CD5C5C"
			        $linkColor = "cyan"
                }	

                if($DefinitionNameMAping[$MailBuild.MailServerDeploy].Equals("Succeeded"))
		        {
			        $ServerColor = "#98FB98"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailServerDeploy].Equals("In Progress"))
		        {
			        $ServerColor = "#FFDAB9"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailServerDeploy].Equals("Failed")  -or $DefinitionNameMAping[$MailBuild.MailServerDeploy].Equals("Not Started") )
		        {
			        $ServerColor = "#CD5C5C"
		        }
                
                if($MailBuild.MailBuildDefinition -eq "Serviceability" -and $GetParameters.Credentials.Project -eq "ISP12")
                {
                    $MailBuild.MailPromotion=$MailBuild.MailSanityTest
                    $MailBuild.MailSanityTest=$MailBuild.MailClientDeploy
                    $MailBuild.MailClientDeploy = "notApplicable"
                    $MailBuild.MailClientErrorMessage=""
                }

                if($DefinitionNameMAping[$MailBuild.MailClientDeploy].Equals("Succeeded"))
		        {
			        $clientColor = "#98FB98"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailClientDeploy].Equals("In Progress"))
		        {
			        $clientColor = "#FFDAB9"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailClientDeploy].Equals("Failed")  -or $DefinitionNameMAping[$MailBuild.MailClientDeploy].Equals("Not Started") -or $DefinitionNameMAping[$MailBuild.MailClientDeploy].Equals("Not Applicable") )
		        {
			        $clientColor = "#CD5C5C"
		        }

                if($DefinitionNameMAping[$MailBuild.MailSanityTest].Equals("Succeeded"))
		        {
			        $SanityColor = "#98FB98"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailSanityTest].Equals("In Progress"))
		        {
			        $SanityColor = "#FFDAB9"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailSanityTest].Equals("Failed")  -or $DefinitionNameMAping[$MailBuild.MailSanityTest].Equals("Not Started") )
		        {
			        $SanityColor = "#CD5C5C"
		        }

		        if($DefinitionNameMAping[$MailBuild.MailPromotion].Equals("Succeeded"))
		        {
			        $promotionColor = "#98FB98"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailPromotion].Equals("In Progress"))
		        {
			        $promotionColor = "#FFDAB9"
		        }
		        elseif($DefinitionNameMAping[$MailBuild.MailPromotion].Equals("Failed")  -or $DefinitionNameMAping[$MailBuild.MailPromotion].Equals("Not Started") )
		        {
			        $promotionColor = "#CD5C5C"
		        }
		        
		
		        $body += "<tr style='border:3px solid black;' >" 

                $body += "<td style='border:3px solid black;' align='center'>"+$MailBuild.MailBuildDefinition+"</td><td bgcolor=$buildColor style='border:3px solid black;'  align='center'><a href="+$link+$MailBuild.MailBuildId+" style='color:$linkColor'>"+$DefinitionNameMAping[$MailBuild.MailBuildResult]+"</a></td><td style='border:3px solid black;' align='center'>"+$MailBuild.MailErrorMessage+"</td>"

                $body += "<td bgcolor=$ServerColor style='border:3px solid black;' align='center'>"+$DefinitionNameMAping[$MailBuild.MailServerDeploy]+"</td><td style='border:3px solid black;' align='center'>"+$MailBuild.MailServerErrorMessage+"</td><td bgcolor=$clientColor style='border:3px solid black;' align='center'>"+$DefinitionNameMAping[$MailBuild.MailClientDeploy]+"</td>" 
        
                $body += "<td style='border:3px solid black;' align='center'>"+$MailBuild.MailClientErrorMessage+"</td><td bgcolor=$SanityColor style='border:3px solid black;' align='center'>"+$DefinitionNameMAping[$MailBuild.MailSanityTest]+"</td><td  style='border:3px solid black;' align='center'>"+$SanityTestUrl[$MailBuild.MailBuildDefinition]+"</td><td bgcolor=$promotionColor style='border:3px solid black;' align='center'>"+$DefinitionNameMAping[$MailBuild.MailPromotion]+"</td>"

                $body += "<td style='border:3px solid black;' align='center'><a href="+$linkRelease+$MailBuild.MailReleaseId+$appendString+$MailBuild.MailReleaseRID+">"+$DefinitionNameMAping[$MailBuild.MailReleaseStatus]+"</a></td>"

                $body += "</tr>"
                $promotionColor = "White"
                $ServerColor = "White"
                $clientColor = "White"
                $SanityColor = "White"
                $buildColor = "white"
	        }
        }
    }

    $body += "</table>"

    $body+="<br><br>"

    $body+= "<table style='border:3px solid black;border-collapse:collapse;'>"

    #$body += "<th ></th><th ></th>"

    $body+= "<tr bgcolor='#98FB98'><td>Build Pass Succeeded Today</td><td></td><td></td></tr>"

    $body+= "<tr bgcolor='#FFDAB9'><td>Build Partially Passed Today</td><td></td><td></td></tr>"

    $body+= "<tr bgcolor='#CD5C5C'><td>Build Failed Today</td><td></td><td></td></tr>"


    $body+= "</table>"

    $sendMail = @{
        MailFrom = $from;
        MailTo = $to;
        MailSubject = $subject;
        MailSMTP = $smtp;
        MailBody =$body;
        MailPort = 25
    }

    $sendMailObject = New-Object PSObject -Property $sendMail 
    
    return $sendMailObject
}