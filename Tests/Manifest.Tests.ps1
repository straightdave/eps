$ModuleName = 'EPS'
$ModulePath = "$(Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent)\$ModuleName"
$ManifestPath = "$ModulePath\$ModuleName.psd1"
$ManifestExists = (Test-Path -Path $ManifestPath)

$IsPowerShell2 = $PSVersionTable.PSVersion -eq '2.0'

Describe 'Module manifest' {
    Context 'Validation' {

        It 'has a manifest' {
            $ManifestExists | Should Be $true
        }

        if ($ManifestExists) {
            $manifest = Test-ModuleManifest -Path $ManifestPath
        }

        It 'has a valid manifest' {
            $manifest | Should Not Be $null
        }

        # ModuleToProcess is required for the module to load in PS v2.0
        # it cannot be tested as it is not exposed in the PSModuleInfo
        #It 'has a valid root module' {
        #    $manifest.RootModule | Should Be "$ModuleName.psm1"
        #}

        It 'has a valid description' {
            $manifest.Description | Should Not BeNullOrEmpty
        }

        It 'has a valid author' -Skip:$IsPowerShell2 {
            $manifest.Author | Should Not BeNullOrEmpty
        }

        It 'has a valid guid' -Skip:$IsPowerShell2 {
            { 
                [guid]::Parse($manifest.Guid) 
            } | Should Not throw
        }

        It 'has a valid copyright' -Skip:$IsPowerShell2  {
            $manifest.CopyRight | Should Not BeNullOrEmpty
        }
    }
}