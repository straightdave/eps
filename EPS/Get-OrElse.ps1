function Get-OrElse {
    Param(
        $Value,

        [Parameter(Mandatory=$True)]
        $DefaultValue
    )
    if ([string]::IsNullOrEmpty($Value)) {
        $DefaultValue
    } else {
        $Value
    }
}