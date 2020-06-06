

function SanityMapping{
    [CmdletBinding()] 
    param
    (
        [Parameter(Mandatory=$true)] 
        [Alias('Credentials')] 
        $GetParameters
    )
    $SanityTestUrl=@{}

    for([int]$i=0;$i -lt  $GetParameters.Credentials.ApplicationCount ; $i++)
    {
        $SanityTestUrl[$GetParameters.ApplicationName[$i]]=$GetParameters.Url[$i]
    }
    return $SanityTestUrl
}
