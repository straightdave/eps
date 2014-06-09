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

$execPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

function Compile-Raw{
  param(
  [string]$raw,
  [switch]$debug = $false
  )

  #========================
  # constants
  #========================
  $pre_cmd = @('$_temp = ""')
  $post_cmd = @('$_temp')
  $put_cmd = '$_temp += '
  $insert_cmd = '$_temp += ' 
  $p = [regex]'(?si)(?<content>.*?)(?<token><%%|%%>|<%=|<%#|<%|%>|\n)'
  
  #========================
  # 'global' variables
  #========================
  $content = ''
  $stag = ''  # start tag
  $line = @()
  $w = $false # whether last tag-pair is <% %>
  
  #========================
  # start!
  #========================
  $pre_cmd | %{ $line += $_ }
  $raw += "`n"
  
  $m = $p.match($raw)
  while($m.success){
    $content = $m.groups["content"].value
    $token = $m.groups["token"].value
    
    if($stag -eq ''){
      
      # escaping characters
      $content = $content -replace '"','`"'
    
      switch($token){
        { $_ -in '<%', '<%=', '<%#'} {
          $stag = $token          
        }
        
        "`n" {
          if( -not $w ) { 
            $content += '`n'
          }
        }
        
        '<%%' {
          $content += '<%'
        }
        
        '%%>' {
          $content += '%>'
        }
        
        default {
          $content += $token
        }
      }
      
      $w = $false
    } 
    else{
      switch($token){
        '%>' {          
          switch($stag){
            '<%' {
              $line += $content
              $w = $true
            }
            
            '<%=' {
              $line += ($insert_cmd + '"' + $content.trim() + '"')
            }
            
            '<%#' { }
          }
          
          $stag = ''
          $content = ''
        }
        
        default {
          $content += $token
        }
      }
    }
    
    if( $content -ne '') { $line += ($put_cmd + '"' + $content + '"') }
    $m = $m.nextMatch()
  }
  
  $post_cmd | %{ $line += $_ }
  $script = ($line -join ';')
  
  if($debug) {
    return $line
  }
  
  $line = $null
  return $script
}


## EPS-Render:
##   Key entrance of EPS
##   Safe mode: start a new PowerShell instance to compile the templates to prevent result from being polluted by variables in current context
function EPS-Render{
  param(
  [string]$template,
  [switch]$safe
  )
  
  if($safe){
    $p = [powershell]::create()
    
    $block = {
      param($temp,$libpath)      
      . $libpath\eps.ps1   # load Compile-Raw
      $script = Compile-Raw $temp      
      $res = iex $script
      write-output $res
    }
    
    [void]$p.addscript($block)
    [void]$p.addparameter("temp",$template)
    [void]$p.addparameter("libpath",$execPath)
    $result = $p.invoke()
    return $result
  }
  else{
    $script = Compile-Raw $template
    $result = iex $script
    return $result
  }
}

#$text = gc .\test.eps
#$text = $tt -join "`n"  # combine to one string with new-line characters as delimiters

#$result = EPS-Render $text -safe
#$result
