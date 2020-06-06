function GetReleases{
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
        $uri= "https://tfsemea1.ta.philips.com/tfs/TPC_Region11/HIT_ISP/_apis/release/releases"
        $releases = Invoke-RestMethod -Method 'Get' -Uri  $uri -Credential $Cred
        return $releases
    }
    catch
    {
        $exMsg= $_.Exception.Message
        Write-Host "Search failed. Exception Message:: $exMsg"
        throw "Search Failed. Exception Message:: $exMsg"
    }
}

