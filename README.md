eps
===

Embedded PowerShell (similar to ERB)

It's crazy to create templating for PowerShell

test.eps:
```
Hi <%= $name %>

Please buy me the following items:
<% 1..5 | %{ %>
  - <%= $_ %> pigs ...
<% } %>

Dave is a <% if($true) { %> boy <% } else { %> girl <% } %>. 

Thanks,
Dave
<%= (Get-Date -f yyyy-MM-dd) %>
```

commands:
```powershell
$text = gc .\test.eps
$text = $text -join "`n"
$name = "ABC"
$script = Compile-Raw $text
iex $script
```


## Log

#### June 5, 2014
current issue(s)

+ ~~cannot recognize '<%%' and '%%>'~~
+ ~~if whole line is one command, need to neglect its new-line synbol~~

#### Jun 6, 2014
fixed two issues, 

## Please help to find more bugs
eyaswoo@163.com

## TODO
+ html and url encoding
+ parameter context
