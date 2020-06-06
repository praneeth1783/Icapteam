
function Get-VSPath
{

$command = "$PSScriptRoot\vswhere.exe -latest -property installationPath -format value"
$VSPath = Invoke-Expression $command

#"Latest VS installation path is $VSPath"

return $VSPath

}