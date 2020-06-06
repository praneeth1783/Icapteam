param(
    [string]$Action = "",
    [string]$FailonError = "false",
    [string]$StopAll = "false",
    [string]$JsonFile = ".\RestartServices.json"
)

$json = Get-Content -Raw -Path $JsonFile | Out-String | ConvertFrom-Json
$AppsToClose = $json.AppsToKill.AppName
$ServicesList = $json.ServicesList.ServiceName
$SystemServicesList = $json.SystemServicesList.SystemServiceName

function SetService ([string]$serviceName, [bool]$start, [bool]$failonerror) {
    try {
        if ((Get-Service -Name $serviceName -ErrorAction Ignore) -eq $null) {
            Write-Output "Service: $serviceName not found."
            return
        }
        $status = Get-WMIObject win32_service -filter "name='$serviceName'" -computer "."
        if ($Status.StartMode -eq "Disabled") {
            Write-Output "Service: $ServiceName is in Disabled state"
            return
        }
        
        if ($FailonError) {
            $errorAction = [System.Management.Automation.ActionPreference]::Stop
        }
        else {
            $errorAction = [System.Management.Automation.ActionPreference]::Ignore
        }

        if ($start) {
            Write-Output "Attempting to start service: $serviceName."
            Start-Service -Name $serviceName -ErrorAction $errorAction
        }
        else {
            Write-Output "Attempting to stop service: $serviceName."
            Stop-Service -Name $serviceName -Force -ErrorAction $errorAction
        }
    }
    catch {
        $exceptionMessage = $_.Exception.Message
        $exceptionItemName = $_.Exception.ItemName

        if ($FailonError) {
            Write-Error "$exceptionMessage $exceptionItemName"
            exit 1
        }
        Write-Output "$exceptionMessage $exceptionItemName"

    }
}

function TaskKill ($processName) {
    try {
        Write-Output "Attempting to kill process: $processName"
        taskkill.exe /im $processName /f 2>&1 | out-null

    }
    catch {
        $exceptionMessage = $_.Exception.Message
        $exceptionItemName = $_.Exception.ItemName
        Write-Output "$exceptionMessage $exceptionItemName"

    }
}

function GetService ([String]$serviceName) {
    try {
        $ServiceStatus = Get-Service -Name $serviceName -ErrorAction Ignore
        if ($ServiceStatus -ne $null) {
            Write-Output "Service '$serviceName' mode is '$($ServiceStatus.StartType)' and in status: '$($ServiceStatus.Status)'"

            $dependentsStart = Get-Service -Name $serviceName -DependentServices
            foreach ($dep_svc in $dependentsStart) {
                Write-Output "Dependent Service '$($dep_svc.ServiceName)' mode is '$($dep_svc.StartType)' and in status: '$($dep_svc.Status)'" 
            }
        }
        else {
            Write-Output "Service $serviceName is not present on this machine"
        }
    }
    catch {
        $exceptionMessage = $_.Exception.Message
        $exceptionItemName = $_.Exception.ItemName
        Write-Output "$exceptionMessage $exceptionItemName"

    }
}

function ExecuteIisreset ($iisrestAction) {
    try {
        Write-Output "Attempting to $iisrestAction iis..."
        iisreset.exe "/$iisrestAction" 
    }
    catch {
        $exceptionMessage = $_.Exception.Message
        $exceptionItemName = $_.Exception.ItemName
        Write-Output "$exceptionMessage $exceptionItemName"
    }
}

$svcStart = $true
$svcStop = $true

[bool]$boolFailOnError = $false
if ($FailonError -eq "true") {
    $boolFailOnError = $true
}

switch ($Action.ToLower()) {
    "start" { $svcStop = $false }
    "stop" { $svcStart = $false }
    Default { }
}

if ($svcStop) {
    foreach ($proc in $AppsToClose) {
        TaskKill $proc
    }

    foreach ($svc in $SystemServicesList) {
        SetService -serviceName $svc -start $false -failonerror $boolFailOnError
    }
    
    foreach ($svc in $ServicesList) { 
        if ((Get-Service -Name $svc -ErrorAction Ignore) -ne $null) {
            $dependentsStart = Get-Service -Name $svc -DependentServices
            foreach ($depsvc in $dependentsStart) {
                SetService -serviceName $depsvc.ServiceName -start $false -failonerror $boolFailOnError
            }
        }
        SetService -serviceName $svc -start $false -failonerror $boolFailOnError
    }
    ExecuteIisreset "stop"

    if ($StopAll -eq "false") {
        foreach ($svc in $SystemServicesList) {
            SetService -serviceName $svc -start $true -failonerror $boolFailOnError
        }
        ExecuteIisreset "start"
    }

}

if ($svcStart) {
    foreach ($svc in $SystemServicesList) {
        SetService -serviceName $svc -start $true -failonerror $boolFailOnError
    }

    foreach ($svc in $ServicesList) {
        SetService -serviceName $svc -start $true -failonerror $boolFailOnError
        if ((Get-Service -Name $svc -ErrorAction Ignore) -ne $null) {
            $dependentsStart = Get-Service -Name $svc -DependentServices
            foreach ($depsvc in $dependentsStart) {
                SetService -serviceName $depsvc.ServiceName -start $true -failonerror $boolFailOnError
            }
        }
    }

    ExecuteIisreset "start"
}
Write-Output "Reporting final service status"
if ($svcStart -or $svcStop) {
    foreach ($svc in $ServicesList) {
        GetService -serviceName $svc
    }
}
