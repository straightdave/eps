EPS
===
EPS (Embedded PowerShell), inspired by erb, is a templating system that embeds PowerShell code into a text document. It is often used to embed PowerShell code in an HTML document, similar to ASP, JSP and PHP.<br/>
The most common use that the author can image is to render reports based on HTML pages (on Windows platforms). Or it may works for a rails-like or sinatra-like framework that somebody creates for PowerShell.

### Usage
EPS allows PowerShell code to be embedded within a pair of <% and %>, or <%= and %>, etc. delimiters. These embedded code blocks are then evaluated in-place (they are replaced by the result of their evaluation).<br/>
Code in <% %> delimiters will be treated as expressions or commands which help to generate text; Code in <%= %> delimiters is treated as values; Text in <%# %> delimiters will be treated as comments which is ignored in compiling process.

Here's the example:

test.eps:
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
$text = gc .\test.eps
$text = $text -join "`n"
$name = "ABC"
EPS-Render $text
# here it uses non-safe mode
# To use safe mode: using 'EPS-Render $text -safe' can compile in another PowerShell instance
# to avoid variables polluted by current context
```

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
$text = gc .\test.eps
$text = $text -join "`n"
EPS-Render $text -safe -binding @{ name = "dave" }
```

_NOTE:_
The sample above is just for current version. It has much space to improve.


### Log

#### June 5, 2014
+ ~~cannot recognize '<%%' and '%%>'~~
+ ~~if whole line is one command, need to neglect its new-line synbol~~

#### Jun 6, 2014
fixed two issues

TODO list:
+ html and url encoding
+ ~~parameter context~~
+ other usability improvements


## Contribute
Please try out and help to find more bugs! 
Author email: eyaswoo@163.com

