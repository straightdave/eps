function Get-OrElse {
    Param(
        $Value,

        [Parameter(Mandatory)]
        $DefaultValue
    )
    if ([string]::IsNullOrEmpty($Value)) {
        $DefaultValue
    } else {
        $Value
    }
}