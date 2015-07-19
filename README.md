EPS
===
This is a fork of the excellent templating tool for powershell found at:
http://straightdave.github.io/eps
Thanks, Dave.

This fork adds following features:
- Pack the function in a Powershell Module
- Rename the 'EPS-Render' function to 'New-EpsResult' to fit the Approved Verbs for Powershell
- Create an Alias 'EPS-Render' for compatibility with old function name.
- Rename the 'Compile-Raw' function to 'New-EpsResult' to fit the Approved Verbs for Powershell
- Create an Alias 'Compile-Raw' for compatibility with old function name.
- Move Functions definitions in own file in a Functions folder

## Original Description

EPS (Embedded PowerShell), inspired by erb, is a templating system that embeds PowerShell code into a text document. It is often used to embed PowerShell code in an HTML document, similar to ASP, JSP and PHP.<br/>
The most common use that the author can image is to render reports based on HTML pages (on Windows platforms). Or it may works for a rails-like or sinatra-like framework that somebody creates for PowerShell.

### Usage
EPS allows PowerShell code to be embedded within a pair of `<%` and `%>`, or `<%=` and `%>`, or other delimiters. These embedded code blocks are then evaluated in-place (they are replaced by the result of their evaluation).<br/>
Code in `<% %>` delimiters will be treated as expressions or commands which help to generate text;<br/>
Code in `<%= %>` delimiters is treated as values;<br/>
Text in `<%# %>` delimiters is treated as comment which is ignored in compiling process.<br/>
_Note_<br/>
You can write multiple-line commands in a ```<% %>```.

#### Command usages
```EPS-Render [[-template] $text] | [-file $a_file_name] [-safe] [-binding $a_hashtable]```<br/><br/>
1. '-template' requires template value of string type <br/>
2. '-file' requires a file name of string type <br/>
3. if '-file' exists, it will omit '-template' value and render template in the file <br/>
4. '-safe' will let it render templates in isolated mode (in another thread/powershell instance) to avoid variable pollution (variable name already in current context) <br/>
5. if '-safe' is used, you should provide variables yourself by using '-binding' option with a hashtable containing k-v pairs <br/>

### Examples:

In the file 'test.eps':
```
Hi <%= $name %>

<%# this is a comment %>
Please buy me the following items:
<% 1..5 | %{ %>
  - <%= $_ %> pigs ...
<% } %>

Dave is a <% if($true) { %> boy <% } else { %> girl <% } %>. 

Thanks,
Dave
<%= (Get-Date -f yyyy-MM-dd) %>
```

Then type some commands:
```powershell
. .\eps.ps1  # don't forget to load

$name = "ABC"
EPS-Render -file test.eps

# here it uses non-safe mode
# To use safe mode: using 'EPS-Render -file test.eps -safe' can compile in another PowerShell instance
# to avoid variables polluted by current context
```
_NOTE_<br/>
__EPS-Render__ accepts a string as inputted template. ```$text``` here is an array so it needs to be concated with ```"`n"```.<br/>
In the following samples you'll see some input are in a ```@' '@``` block which is a string.

It will produce:
```
Hi ABC

Please buy me the following items:
  - 1 pigs ...
  - 2 pigs ...
  - 3 pigs ...
  - 4 pigs ...
  - 5 pigs ...

Dave is a boy.

Thanks,
Dave
2014-06-09
```

Or you can use safe mode with data bindings:
```powershell
EPS-Render -file $file_name -safe -binding @{ name = "dave" }
```

### More examples and notes
+ any result from a ```<% %>``` pair will be placed at the top

```powershell
$template = @'
Hi, dave is a <% if($true) { "boy" } else { "girl" } %>
'@

EPS-Render -template $template
```
will produce:
```
boy
Hi, dave is a 
```

also, if template is
```
Hi dave
Don't watch TV.

Your wife
<% get-date -f yyyy-MM-dd %>
```
will produce:
```
2014-06-10
Hi dave
Don't watch TV.

Your wife
```
_NOTE_<br/>
```<%= $(get-date -f yyyy-MM-dd) %>``` produces the date string at the same place.

+ you can use multi-line <% %> block

such as:
```powershell
$template = @'

<%
  $name = "dave"
  
  1..5 | %{
    "haha"
  }
%>

Hello, I'm <%= $name %>.
'@

EPS-Render -template $template
```
it will produce:
```
haha
haha
haha
haha
haha

Hello, I'm dave.
```

Remember if you add variables in the template directly, they will be used in that template.


## Contribute
Please try out and help to find more bugs! 
Author's email: eyaswoo@163.com
