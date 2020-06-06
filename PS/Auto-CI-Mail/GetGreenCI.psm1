

function GetGreenCIStatus{
    [CmdletBinding()] 
    param
    (
        [Parameter(Mandatory=$true)] 
        [Alias('Total Builds')] 
        [int]$TotalMailedBuildCount,
         
        [Parameter(Mandatory=$true)] 
        [Alias('Succeded builds')] 
        [int]$includedBuildCount
    )
    if($TotalMailedBuildCount -eq $includedBuildCount)
    {
        $GreenCIJson=@{Title="Overall CI status";LastGreenCIDate=(Get-Date).GetDateTimeFormats()[0]} | ConvertTo-Json -Compress
        $GreenCIJson | Out-File "$DropPath\\HIT_ISP_GreenCI.json"
    }
}

