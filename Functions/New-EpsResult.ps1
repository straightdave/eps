#######################################################
##
##  EPS - Embedded PowerShell
##  Dave Wu, June 2014
##
##  Templating tool for PowerShell
##  For detailed usage please refer to:
##  http://straightdave.github.io/eps
##
#######################################################

# $execPath   = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
# $thisfile   = "$execPath\eps.ps1"
# $sysLibFile = "$execPath\sys_lib.ps1"  # import built-in resources to eps file

## New-EpsResult:
##
##   Key entrance of EPS
##   Safe mode: start a new/isolated PowerShell instance to compile the templates
##   to prevent result from being polluted by variables in current context
##   With Safe mode: you can pass a hashtable containing all variables to this function.
##   Compiling process will inject values recorded in hashtable to template
##
## Usage:
##
##    New-EpsResult [[-template] <text>]|[-file <file name>] [-safe] [-binding <hashtable>]
##
## Examples:
##   - New-EpsResult -template $text
##     will use current context to fill variables in template. If no '$name' exists in current context, it will produce blanks.
##   - New-EpsResult -template $text -safe -binding @{ name = "dave" }
##     will use "dave" to render the placeholder "<%= $name %>" in template
##
## Other example:
##   $result = New-EpsResult -file $a_file -safe -binding @{ name = "dave" }
##   *Note*: here using safe mode
##
##   or
##
##   $text = @'
##   Dave is a <% if($true){ %>man<% }else{ %>lady<% } %>.
##   Davie is <%= $age %>.
##   '@
##
##   $age = 26
##   $result = New-EpsResult -template $text
##
function New-EpsResult{
  param(
  [string]$template   = "",
  [string]$file       = "",
  [hashtable]$binding = @{},
  [switch]$safe
  )

  $FunctionsPath = $PSScriptRoot
  $GetEpsRawPath = Join-path $FunctionsPath 'Get-EpsRaw.ps1'

  write-host $GetEpsRawPath

  if($file -and (test-path $file)){
    $temp1 = gc $file
    $template = $temp1 -join "`n"
  }

  if($sysLibFile -and (test-path $sysLibFile)){
    $template = "<% . $sysLibFile %>`n" + $template
  }

  if($safe){
    $p = [powershell]::create()

    $block = {
      param(
      $temp,
      $lib,
      $binding = @{}    # variable binding
      )
      try {

        . $lib  # load Get-EpsRaw
        $binding.keys | %{ nv -Name $_ -Value $binding[$_] }
        $script = Get-EpsRaw $temp
        $res = iex $script
        write-output $res

      } catch {
        Write-output "$($_.Exception.Message)"
        throw
      }
    }

    [void]$p.addscript($block)
    [void]$p.addparameter("temp",$template)
    [void]$p.addparameter("lib","Z:\src\github\eps\functions\get-epsraw.ps1")
    [void]$p.addparameter("binding",$binding)
    $p.invoke()

  } else {
    $script = Get-EpsRaw $template
    iex $script
  }

}

