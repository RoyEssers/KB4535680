# KB4535680
Please test these script before use.

Get-BitlockerIssues.ps1
This script retrieves events from the Bitlocker eventlog which indicate secure boot cannot be used for integrity.
You could  this as a "script" in MEMCM/SCCM and run in on a collection to get insights.

Test-PCR7Binding.ps1
This script used msinfo32 to determine if PCR7 binding. 
You could  this as a "script" in MEMCM/SCCM and run in on a collection to get insights.

Invoke-KB4535680.ps1
Script installs msu files, and in case of secure boot integrity issues, suspends Bitlocker for 3 reboots. 
This script can be used as an install command for an application in MEMCM/SCCM. 

Detect-KB4535680.ps1
This script checks if KB4535680 is installed.
This script can be used as an detection method for an application in MEMCM/SCCM.
