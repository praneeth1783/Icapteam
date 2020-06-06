param(
    [string[]]$Files_list
)
function Check_versions ([string]$local_file,$tf_command) {
    
    [string]$file_info = & $tf_command info $local_file | ForEach-Object { if ($_ -match "Changeset" ) { $_.Split(" ")[-1] } }
    [string[]]$changeset_list = $file_info.Split(" ")

    Write-Output "[INFO] Changeset Version from Local is : $($changeset_list[0])"  
    Write-Output "[INFO] Cahngeset Version from TFS is :  $($changeset_list[1])"
        
    if ( $changeset_list[0] -ne $changeset_list[1]  ) {
        Write-Output "[INFO] The changeset version is different from workspace and TFS, Going to call rename action"
        Copy-Item $local_file "$local_file.tmp" -Force
		Write-Output "[INFO] Refreshing latest file from TFS"
		& $tf_command undo $local_file /noprompt
        & $tf_command get $local_file
        Move-Item "$local_file.tmp" $local_file -Force
        $Final_Files_list.Add($local_file)
    }
    else {
        Write-Output "[INFO] Changeset version is same in both TFS and Workspace"
        $Final_Files_list.Add($local_file)
    }
}

function Checkin_file($files_to_checkin,$tf_command) {
    &$tf_command checkout $files_to_checkin   
    if ("$env:BUILD_BUILDNUMBER" -eq "" ) {
        $BUILD_NUMBER = Get-Date -UFormat %Y%m%d_%H%M%S
    }
    else {
        $BUILD_NUMBER = $env:BUILD_BUILDNUMBER
    }   
    & $tf_command checkin $files_to_checkin  /comment:"Build Version : $BUILD_NUMBER ***NO_CI***" /bypass /noprompt /force /override:"updated by build" /notes:"ReviewID=00000"
    if ($?) {
        Write-Output "[INFO] File Chekin is successful for $files_to_checkin "
        exit 0
    }
    else {
        throw "File Checkin is failed"
    }
}

$Final_Files_list = New-Object System.Collections.ArrayList
try {
    Import-Module -Global -Name $PSScriptRoot\Modules\FindVisualStudioPath.psm1 -Verbose
    $VSPath = Get-VSPath
    $CommandLocation = "$VSPath\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe"

    if($env:BUILD_SOURCETFVCSHELVESET)
    {
        Write-Output "[INFO] Build is running with Shelveset, Exiting...."
        exit 0
    }

    if( $env:BUILD_SOURCEVERSION -notmatch '^\d+$'){
        Write-Output "[INFO] Build is running with either old changeset or Label, Exiting...."
        exit 0
    }

    if ( $Files_list.Count -gt 0 ) {
        foreach ( $i in $Files_list ) {
            Check_versions -local_file $i  -tf_command $CommandLocation
        }

        if (( $Final_Files_list.Count -ne 0 ) -and ( $Files_list.Count -eq $Final_Files_list.Count)) {
            Checkin_file -files_to_checkin $Final_Files_list -tf_command $CommandLocation
        }
    }
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Error -Message "[ERROR] $ErrorMessage"
    exit -1    
}