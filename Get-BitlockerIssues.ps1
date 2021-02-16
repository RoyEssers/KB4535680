#https://docs.microsoft.com/en-us/windows-hardware/test/hlk/testref/954cf796-a640-4134-b742-eaf0ed2663ff
#script to readbitlocker eventlog and return back secure boot issues, which result in PDR Binding Not Possible
Get-WinEvent -FilterHashTable @{ LogName = 'Microsoft-Windows-BitLocker/BitLocker Management';StartTime=$(Get-Date).AddDays(-1)} -ErrorAction SilentlyContinue | 
    Where-Object { ($_.Message -like '*BitLocker cannot use Secure Boot for integrity*') -or  ($_.Id -eq 770) } | select -Unique -ExpandProperty Message