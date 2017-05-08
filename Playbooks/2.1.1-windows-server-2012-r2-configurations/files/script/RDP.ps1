 #REQUIRES -Version 2.0
 <#
 Last Modified: 11-Apr-2017
 Usage:			Enable/Disable RDP for particular user
 Example:		RDP.ps1 -Action Enable -User user
 #>
 param(
[Parameter(Mandatory=$true)][string]$Action,
[string]$User
)

if("Enable","Disable" -NotContains $Action)
{
Echo "Invalid Action Specified, Only Enable/Disable is allowed."
}
else
{
if($Action -eq "Enable")
{
#Reg add "HKLM\SYSTEM\CurentControlSet\Control\Terminal Server"  /v fDenyTSConnections /t REG_DWORD /d 0 /f
(Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1) | Out-Null
#Below will set NETWORK level authentication to less secure, 1 to more secure
(Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null
}
if($Action -eq "Disable")
{
#Reg add "HKLM\SYSTEM\CurentControlSet\Control\Terminal Server"  /v fDenyTSConnections /t REG_DWORD /d 0 /f
(Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(0,1) | Out-Null
}
if($User -ne "")
{
NET LOCALGROUP "Remote Desktop Users" /ADD $User
}
}