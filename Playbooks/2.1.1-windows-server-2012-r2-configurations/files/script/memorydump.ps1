 #REQUIRES -Version 2.0
 <#
 Last Modified: 11-Apr-2017
 Usage:			Modify Memory Dump option
 Example:		memorydump.ps1 -DebugInfoType 7 -AutoReboot false
 Explanation:	Set the debug info type to automatic memory dump and set auto reboot to false
 DebugInfoType Value
 0 = None
 1 = Active memory dump
 2 = Kernel memory dump
 3 = Small memory dump
 7 = Automatic memory dump
 #>
 param(
[Parameter(Mandatory=$true)][string]$DebugInfoType,
[string]$AutoReboot
)
$wmiobject = Get-WmiObject Win32_OSRecoveryConfiguration -EnableAllPrivileges;
if($AutoReboot -eq "true")
{
$output = $wmiobject | Set-WmiInstance -Arguments @{AutoReboot=$true}
echo "Successfully enable auto reboot"
}
if($AutoReboot -eq "false")
{
$output = $wmiobject | Set-WmiInstance -Arguments @{AutoReboot=$False}
echo "Successfully disable auto reboot"
}
if("0","1","2","3","7" -Contains $DebugInfoType)
{
$output = $wmiobject | Set-WmiInstance -Arguments @{DebugInfoType=$DebugInfoType}
echo "Successfully set the debuginfotype"
}