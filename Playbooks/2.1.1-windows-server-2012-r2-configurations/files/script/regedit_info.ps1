 #REQUIRES -Version 2.0
 <#
 Last Modified: 10-Apr-2017
 Usage:			Query the registry key value
 Example:		regedit_info.ps1 -path HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -key EnableLUA
 #>
 param(
 [Parameter(Mandatory=$true)][string]$path,
 [Parameter(Mandatory=$true)][string]$key
)
 Get-Item -Path Registry::$path | ForEach-Object {Get-ItemProperty $_.pspath} | select $key