$binding = $False
Start-Process msinfo32.exe -ArgumentList @('/report',"$env:temp\msinfo.txt") -Wait
if (select-string -Path "$env:temp\msinfo.txt" -Pattern "Binding Not Possible"){$binding = $True}else{$binding = $False}
Get-Item "$env:temp\msinfo.txt" | Remove-Item -Force | Out-Null
return $binding