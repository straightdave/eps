function Get-OrElse {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $True,
        Position=0)]
        [Object]$Value,

        [Parameter(Mandatory = $True,
            ParameterSetName='Default',
            Position=1)]
        [Object]$Default,
        [Parameter(Mandatory = $True,
            ParameterSetName='Throw')]
        [switch]$Throw
    )
    if ([string]::IsNullOrEmpty($Value)) {
        if ($Throw)
        {
            throw 'Value was null in Get-OrElse'
        }
        $Default
    } else {
        $Value
    }
}