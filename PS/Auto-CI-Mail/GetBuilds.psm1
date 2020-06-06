
function GetBuilds{
    [CmdletBinding()] 
    param
    (
        [Parameter(Mandatory=$true)] 
        [Alias('Credentials')] 
        $GetParameters
    )
    try
    {
        $user = $GetParameters.Credentials.User
        $SecurePassWord = ConvertTo-SecureString -AsPlainText  $GetParameters.Credentials.PassWord -Force
        $Cred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $user,$SecurePassWord
        $uri= "https://tfsemea1.ta.philips.com/tfs/TPC_Region11/HIT_ISP/_apis/build/builds"
        $builds = Invoke-RestMethod -Method 'Get' -Uri  $uri -Credential $Cred
        $buildObj = $builds.value
        if($GetParameters.Credentials.Project -eq "ISP11")
        {
            $builds_isp =   $builds.value

            $uri_nm= "https://tfsemea1.ta.philips.com/tfs/TPC_Region11/HIT_NM/_apis/build/builds"
            $builds_nm = Invoke-RestMethod -Method 'Get' -Uri  $uri_nm -Credential $Cred 
            $nm_builds = $builds_nm.value

            $uri_mr= "https://tfsemea1.ta.philips.com/tfs/TPC_Region11/HIT_MR/_apis/build/builds"
            $builds_mr = Invoke-RestMethod -Method 'Get' -Uri  $uri_mr -Credential $Cred
            $mr_builds = $builds_mr.value

            $buildObj = $builds_isp + $nm_builds +$mr_builds
            

        }
        return $buildObj
    }
    catch
    {
        $exMsg= $_.Exception.Message
        Write-Host "Search failed. Exception Message:: $exMsg"
        throw "Search Failed. Exception Message:: $exMsg"
    }
}

