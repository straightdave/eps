function Get-OrElse {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $True)]
        [Object]$Value,

        [Parameter(Mandatory = $True)]
        [Object]$Default
    )
    if ([string]::IsNullOrEmpty($Value)) {
        $Default
    } else {
        $Value
    }
}