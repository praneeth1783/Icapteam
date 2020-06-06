param(
    [string]$Action="",
    [string]$FailonError="false",
    [string]$StopAll="false"
    )

function SetService ([string]$serviceName, [bool]$start, [bool]$failonerror) {
    try {
            if((Get-Service -Name $serviceName -ErrorAction Ignore) -eq $null)
            {
                Write-Output "Service: $serviceName not found."
                return
            }
        
            if($FailonError){
                $errorAction= [System.Management.Automation.ActionPreference]::Stop
            }
            else {
                $errorAction= [System.Management.Automation.ActionPreference]::Ignore
            }

            if($start) {
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

           if($FailonError){
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

$systemServices = @(
    "W3SVC",
    "WAS",
    "NetTcpPortSharing"
)

$services = @(
    "GfnDicomAccess",
    "LoggerSvc",
    "psa",
    "machine-learning",
    "E2EService",
    "GfnApplicationService",
    "ISPwebsecure",
    "PhilipsUtilityService",
    "PSCServiceHost",
    "RSD_Service",
    "ConcertoScalabilityDaemon",
    "ConcertoFederationDaemon",
    "DicomLoadBalancerService",
    "ConcertoLoadBalanceService",
    "ConcertoCentralizedStorageManagementService",
    "CDBDispSvc",
    "RabbitMQ",
    "AuditLogService"
)

$processes = @(
    "AVAServer.exe",
	"BMAPServer.exe",
    "BrainPerfusionServer.exe",
    "CalciumScoringServer.exe",
    "CardiacViewerServer.exe",
    "CCAServer.exe",
    "CTViewerServer.exe",
    "DentalServer.exe",
    "FilmViewServer.exe",
    "FunctionalCTServer.exe",
    "Generic2DServer.exe",
    "LiverServer.exe",
    "LungDensityServer.exe",
    "LungNodulesServer.exe",
    "SpectralServer.exe",
    "VCServer.exe",
    "Servlethost.exe",
    "Servlethost32.exe",
    "w3wp.exe"
)

$svcStart = $true
$svcStop = $true

[bool]$boolFailOnError=$false
if($FailonError -eq "true"){
    $boolFailOnError=$true
}

switch ($Action.ToLower()) {
    "start" { $svcStop = $false }
    "stop" { $svcStart = $false }
    Default {}
}

if ($svcStop) {
    foreach($proc in $processes) {
    TaskKill $proc
    }

    foreach($svc in $systemServices) {
        SetService -serviceName $svc -start $false -failonerror $boolFailOnError
        }
    
    ExecuteIisreset "stop"

    foreach($svc in $services) {
        SetService -serviceName $svc -start $false -failonerror $boolFailOnError
    }
    

    if($StopAll -eq "false"){
        foreach($svc in $systemServices) {
            SetService -serviceName $svc -start $true -failonerror $boolFailOnError
            }
        ExecuteIisreset "start"
    }

}

if ($svcStart) {
    foreach($svc in $systemServices) {
        SetService -serviceName $svc -start $true -failonerror $boolFailOnError
        }
    
    ExecuteIisreset "restart"

    for ($i = $services.Count-1; $i -gt -1; $i--) {
        SetService -serviceName $services[$i] -start $true -failonerror $boolFailOnError
    }

}
