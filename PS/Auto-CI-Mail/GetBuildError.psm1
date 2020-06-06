function GetBuildError
{
    [CmdletBinding()] 
    param
    (
        [Parameter(Mandatory=$true)] 
        [Alias('Json oject retrieved from error url')] 
        $errorJson,

        [Parameter(Mandatory=$true)] 
        [Alias('Matching String')] 
        [String]$Match,

        [Parameter(Mandatory=$true)] 
        [Alias('Spliting String')] 
        [String]$split
    )
    Write-Host "Failed Build $($MailBuild.MailBuildId)"
    $DropLocation = $GetParameters.Credentials.DropPath
    $errorObjects = ConvertFrom-Json -InputObject $errorJson
    if($errorObjects.count -eq 0)
    {
        $FetchErrorContent="Build Stopped or Cancelled"
        return  $FetchErrorContent
    }
    foreach($errorObject in $errorObjects.value)
    {
        $TempErrorObject = $errorObject.url
        $user = $GetParameters.Credentials.User
        $SecurePassWord = ConvertTo-SecureString -AsPlainText  $GetParameters.Credentials.PassWord -Force
        $Cred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $user,$SecurePassWord
        $erroContent = Invoke-WebRequest -Method 'Get' -Uri  $TempErrorObject -Credential $Cred
        $filenameLog = $DropLocation+"\LogId"+"_"+$MailBuild.MailBuildId+"_"+$errorObject.Id+"_"+$dateToday+".txt"
        $filenameContent = $DropLocation+"\Content"+"_"+$MailBuild.MailBuildId+"_"+$errorObject.Id+"_"+$dateToday+".txt"
        $fileGeterror =  $DropLocation+"\GetError.txt"
        if(Test-Path -Path $filenameLog)
        {
            Clear-Content $filenameLog
        }
        if(Test-Path -Path $filenameContent)
        {
            Clear-Content $filenameContent
        }
            
        add-content $filenameLog $erroContent.Content
        $FinalErrorContent = ""
        $OFS = "`r`n`r`n"

        gc $filenameLog | % { if($_ -match $Match)  {$FinalErrorContent+= $_ +$OFS}}

        if($FinalErrorContent -ne "")
        {
            add-content $filenameContent $FinalErrorContent

            $GetError = Get-Content $filenameContent -First 1

            Write-Host $GetError
            $TrinString = $GetError.Split($split)[1].Trim()
            Write-Host $TrinString
            add-content $fileGeterror $TrinString
        }
    }
    if(Test-Path -Path $fileGeterror)
    {
        $FetchErrorContent = Get-Content $fileGeterror -First 1
        Clear-Content $fileGeterror
        if($FetchErrorContent -eq $null)
        {
            $FetchErrorContent="NA"
        }
        return $FetchErrorContent
    }
    else
    {
        $FetchErrorContent="NA"
        return  $FetchErrorContent
    }
    
    
}