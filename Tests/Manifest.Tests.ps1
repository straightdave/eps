$ModuleName = 'EPS'
$ModulePath = "$(Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent)\$ModuleName"
$ManifestPath = "$ModulePath\$ModuleName.psd1"
$ManifestExists = (Test-Path -Path $ManifestPath)

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

        It 'has a valid root module' {
            $manifest.RootModule | Should Be "$ModuleName.psm1"
        }

        It 'has a valid description' {
            $manifest.Description | Should Not BeNullOrEmpty
        }

        It 'has a valid author' {
            $manifest.Author | Should Not BeNullOrEmpty
        }

        It 'has a valid guid' {
            { 
                [guid]::Parse($manifest.Guid) 
            } | Should Not throw
        }

        It 'has a valid copyright' {
            $manifest.CopyRight | Should Not BeNullOrEmpty
        }
    }
}