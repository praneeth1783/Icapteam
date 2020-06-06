
<#
.Synopsis
  Fetching the Assemble discription of all binaries in teh given path

.Description
  Author: chaithra m chaithra.m@philips.com
  Last Updated: 11/05/2020

.Example 
  .\Extract_BinaryInfo.ps1 -Path "anyfolder_containing_binaries" 
   
#>
Param (
    [Parameter(Mandatory=$true)] 
    [Alias("BinariesPath")] 
    [string]$path
    ) 
    
try
{
    $List = Get-ChildItem $path *.dll -Recurse | Select-Object FullName
    Clear-Content "$path\BinaryInfo.csv"

    foreach($file in $List)
    {
        Write-Output $file.FullName
        try
        {
            #fetching the details of the AssembleDiscription attribute from teh dlls
            $valuetodisplay= [Reflection.Assembly]::ReflectionOnlyLoadFrom($file.FullName).CustomAttributes | Where-Object {$_.AttributeType.Name -eq "AssemblyDescriptionAttribute" } | Select-Object -ExpandProperty ConstructorArguments | Select-Object -ExpandProperty value
        }
        catch
        {
            Write-Output "Exception - but continue"
        }
        if(![string]::IsNullOrEmpty($valuetodisplay))
        {
            $filename= $file.FullName
            Write-Output $valuetodisplay
            Add-Content "$path\BinaryInfo.csv" "FileName: $filename AssemblyDescriptionAttribute: $valuetodisplay" #adding output value to txt file for reference
        }
        }
}
catch
{
    Write-Error "$($_.Exception.Message)"
} 


