<#
.SYNOPSIS
    Install a Microsoft patch through wusa.exe

.DESCRIPTION
    THis script verifies if there are any bitlocker related eventids which cause bitlocker recovery after installing KB4535680, and suspens bitlocker for 3 reboots if found.

.NOTES
    FileName:    Invoke-KB4535680.ps1
    Author:      Roy Essers
    Created:     2021-04-02

    Version history:
    1.0.0 - (2021-04-02) Script created
#>

$VerbosePreference = 'Continue'
$LogPath = "$env:windir\Temp"
Get-ChildItem "$LogPath\*.log" | Where-Object LastWriteTime -LT (Get-Date).AddDays(-15) | Remove-Item -Confirm:$false
$LogFile = Join-Path -Path $LogPath -ChildPath "$($MyInvocation.MyCommand.Name)-$(Get-Date -Format 'yyyy.MM.dd-HH.mm').log"
Start-Transcript $LogFile

$BitlockerEvents = Get-WinEvent -FilterHashTable @{ LogName = 'Microsoft-Windows-BitLocker/BitLocker Management';StartTime=$(Get-Date).AddDays(-7)} -ErrorAction SilentlyContinue | 
    Where-Object { ($_.Message -like '*BitLocker cannot use Secure Boot for integrity*') -or  ($_.Id -eq 770) } | Select-Object -Unique -ExpandProperty Message

#suspent bitlocker to prevent issue after installing KB4535680
if ($BitlockerEvents){
    Suspend-BitLocker -MountPoint 'c:' -RebootCount 3 | Out-Null
}

$FileTime = Get-Date -format 'yyyy.MM.dd-HH.mm'
$Updates = (Get-ChildItem . | Where-Object {$_.Extension -eq '.msu'} | Sort-Object {$_.LastWriteTime} )
$iUpdates = $Updates.count

if (-not(Test-Path $env:systemroot\SysWOW64\wusa.exe))
{
  $wusa = "$env:systemroot\System32\wusa.exe"
}
else
{
  $wusa = "$env:systemroot\SysWOW64\wusa.exe"
}


if (Test-Path $LogPath\Wusa.evtx)
{
  Rename-Item -Path $LogPath\Wusa.evtx -NewName $LogPath\Wusa.$FileTime.evtx
}

foreach ($Update in $Updates)
{
  Write-Information "Starting Update $iUpdates - `r`n$Update"
  Start-Process -FilePath $wusa -ArgumentList ($Update.FullName, '/quiet', '/norestart', "/log:$env:HOMEDRIVE\Temp\Wusa.log") -Wait
  Write-Information "Finished Update $iUpdates"
  if (Test-Path $LogPath\Wusa.log)
  {
    Rename-Item -Path $LogPath\Wusa.log -NewName $LogPath\Wusa.$FileTime.evtx
  }
  Write-Information '-------------------------------------------------------------------------------------------'
  $iUpdates = --$iUpdates
}
Stop-Transcript

#return soft reboot
Exit 3010