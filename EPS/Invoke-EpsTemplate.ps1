Set-StrictMode -Version 3
$ErrorActionPreference = "Stop"
function Invoke-EpsTemplate {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
    Param(
        [Parameter(ParameterSetName='String template')]
        [String]$Template,

        [Parameter(ParameterSetName='File template')]
        [String]$Path,

        [Parameter(ValueFromPipeline=$True, ValueFromPipelinebyPropertyName=$True)]
        [Hashtable]$Binding = @{},

        [switch]$Safe
    )   
    
    if ($Path) {
        $Template = Get-Content -Raw $Path
    }

    $script = New-TemplateScript -Template $Template
    Write-Verbose "Executing script @'`n$($script | ConvertTo-Json)`n'@."

    if($Safe) {
        $block = {
            Param([String]$Script, [Hashtable]$Binding)

            $Binding.GetEnumerator() | ForEach-Object { New-Variable -Name $_.Key -Value $_.Value }
            Invoke-Expression $Script      
        }

        try {
            $powershell = [powershell]::Create()
            $powershell.
                AddScript($block).
                AddParameter("Binding", $Binding).
                AddParameter("Script", $script).
                Invoke()[0]
        } finally {
            if ($powershell) {
                $powershell.Dispose()
            }
        }
    } else {
        $variablesToDefine = $Binding.GetEnumerator() | ForEach-Object { New-Object PSVariable @($_.Key, $_.Value) }
        $templateScriptBlock.InvokeWithContext(@{}, $variablesToDefine)
    }
}