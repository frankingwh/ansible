 #REQUIRES -Version 2.0
 <#
 Last Modified: 11-Apr-2017
 Usage:			Modify Page File Setting
 Example:		pagefile.ps1 -AutoManage true
 Explanation	Set to auto manage
 Example:		pagefile.ps1 -AutoManage false -MinSize 1024 -MaxSize 2048
 Explanation:	Set the page file with 1024MB Minimum size and 2048MB maximum size
 #>
 param(
[Parameter(Mandatory=$true)][string]$AutoManage,
[string]$MinSize,
[string]$MaxSize
)

$computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges;

if($AutoManage -eq "true")
{
$computersys.AutomaticManagedPagefile = $true
$output = $computersys.Put();
echo "Successfully Set the Page File to Automatic Managed"
}
if($AutoManage -eq "false")
{
$computersys.AutomaticManagedPagefile = $false
$output = $computersys.Put();
$pagefile = Get-WmiObject -Query "Select * From Win32_PageFileSetting Where Name like '%pagefile.sys'";
if($MinSize -ne "")
{
$pagefile.InitialSize = $MinSize
}
if($MaxSize -ne "")
{
$pagefile.MaximumSize = $MaxSize
}
$output = $pagefile.Put();
echo "Successfully Set the Page File"
}
