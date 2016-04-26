<#
.SYNOPSIS
    Invoke Pester in an Appveyor build context.

.DESCRIPTION
    This script is meant to be called from the appveyor.yml descriptor.

.EXAMPLE
    Appveyor.Pester.ps1
    
    Runs all the unit tests and collects results in NUnit XML format.

.EXAMPLE
    Appveyor.Pester.ps1 -Finalize
    
    Collect XML output, upload tests, and indicate build errors.

.PARAMETER Version
    Version of powershell we are running on. This is a hack to circumvent
    the fact that PS 5.0 does not reflect the -Version value in 
    $PSVersionTable
    
.PARAMETER Finalize
    The script is run in `finalize` mode, meaning we are collecting
    and uploading error data.

#>
[cmdletbinding()]
Param(
    [string]$Version,
    [switch]$Finalize
)
# Source: https://github.com/RamblingCookieMonster/PSDiskPart/blob/master/Tests/appveyor.pester.ps1

$PSVersion = $Version
$TestFile = "TestResultsPS$PSVersion.xml"
$ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
Set-Location $ProjectRoot


#Run a test with the current version of PowerShell
if(-not $Finalize)
{
    "`n`tSTATUS: Testing with PowerShell $PSVersion`n"

    Import-Module Pester

    Invoke-Pester -Path "$ProjectRoot\Tests" -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile" -PassThru |
        Export-Clixml -Path "$ProjectRoot\PesterResults$PSVersion.xml"
}

#If finalize is specified, check for failures and 
else
{
    #Show status...
        $AllFiles = Get-ChildItem -Path $ProjectRoot\*Results*.xml | Select -ExpandProperty FullName
        "`n`tSTATUS: Finalizing results`n"
        "COLLATING FILES:`n$($AllFiles | Out-String)"

    #Upload results for test page
        Get-ChildItem -Path "$ProjectRoot\TestResultsPS*.xml" | Foreach-Object {
    
            $Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
            $Source = $_.FullName

            "UPLOADING FILES: $Address $Source"

            (New-Object 'System.Net.WebClient').UploadFile( $Address, $Source )
        }

    #What failed?
        $Results = @( Get-ChildItem -Path "$ProjectRoot\PesterResults*.xml" | Import-Clixml )
        
        $FailedCount = $Results |
            Select -ExpandProperty FailedCount |
            Measure-Object -Sum |
            Select -ExpandProperty Sum

        if ($FailedCount -gt 0) {

            $FailedItems = $Results |
                Select -ExpandProperty TestResult |
                Where {$_.Passed -notlike $True}

            "FAILED TESTS SUMMARY:`n"
            $FailedItems | ForEach-Object {
                $Test = $_
                [pscustomobject]@{
                    Describe = $Test.Describe
                    Context = $Test.Context
                    Name = "It $($Test.Name)"
                    Result = $Test.Result
                }
            } |
                Sort Describe, Context, Name, Result |
                Format-List

            throw "$FailedCount tests failed."
        }
}
