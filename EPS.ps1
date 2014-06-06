function Compile-Raw{
  param([string]$raw)  

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
      switch($token){
        { $_ -in '<%', '<%=', '<%#'} {
          $stag = $token
          if( $content -ne '') { $line += ($put_cmd + '"' + $content + '"') }
          $content = ''
        }
        
        "`n" {
          if( -not $w ) { 
            $content += '`n'
          }
          $line += ($put_cmd + '"' + $content + '"')
          $content = ''
        }
        
        '<%%' {
          $content += '<%'
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
              $line += ($insert_cmd + '"' + $content.trim() + '"' )
            }
            
            '<%#' { }            
          }
          
          $stag = ''
          $content = ''
        }
        
        '%%>' {
          $content += '%>'
        }
        
        default {
          $content += $token
        }
      }
    }
  
    $m = $m.nextMatch()
  }
  
  if( $content -ne '' ) { $line += ($put_cmd + '"' + $content + '"') }
  $post_cmd | %{ $line += $_ }
      
  $script = ($line -join ';')
  $line = $null
  return $script
}


$tt = gc .\test.eps
$tt = $tt -join "`n"

$result = Compile-Raw($tt)
$result
