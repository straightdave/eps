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
        [Hashtable]$Helpers = @{},

        [switch]$Safe
    )   
    
    if ($PSCmdlet.ParameterSetName -eq 'File template') {
        $rootedPath = $Path
        if (![IO.Path]::isPathRooted($Path)) {
            $rootedPath = Join-Path (Get-Location) $Path
        }
        
        $Template = [IO.File]::ReadAllText($rootedPath)
    }

    $templateScriptBlock = New-EpsTemplateScript -Template $Template
    Write-Verbose "Executing script @'`n$templateScriptBlock`n'@."

    if($Safe) {
        $block = {
            Param([ScriptBlock]$Script, [Hashtable]$Binding)

            $Binding.GetEnumerator() | ForEach-Object { New-Variable -Name $_.Key -Value $_.Value }
            $Script.Invoke()
        }

        try {
            $powershell = [powershell]::Create()
                        
            foreach($h in $helpers.GetEnumerator()) {
                $powershell = $powershell.AddScript("function $($h.key) { $($h.value) }")
            }
            $powershell.`   
                AddScript("function Each { $function:Each }").`
                AddScript("function Get-OrElse { ${function:Get-OrElse} }").`             
                AddScript($block).`
                AddParameter("Binding", $Binding).`
                AddParameter("Script", $templateScriptBlock).`
                Invoke()
        } finally {
            if ($powershell) {
                $powershell.Dispose()
            }
        }
    } else {
        if ($templateScriptBlock.psobject.Methods['InvokeWithContext']) {
            # InvokeWithContext was introduced in PowerShell version 3.0
            $variablesToDefine = $Binding.GetEnumerator() | 
                ForEach-Object { New-Object System.Management.Automation.PSVariable @($_.Key, $_.Value) }
            $templateScriptBlock.InvokeWithContext($helpers, $variablesToDefine)
        } else {
            $Binding.GetEnumerator() | ForEach-Object { New-Variable -Name $_.Key -Value $_.Value }
            $templateScriptBlock.Invoke()
        }
    }
}
