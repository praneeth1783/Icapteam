function GetCredentials{
    [CmdletBinding()] 
    param
    (
        [Parameter(Mandatory=$true)] 
        [Alias('Jsonfile name')] 
        [String]$FileName
    )
    $GetParameters = Get-Content $FileName | Out-String | ConvertFrom-Json
    return $GetParameters
}

