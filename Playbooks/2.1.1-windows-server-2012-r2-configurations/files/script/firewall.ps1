 #REQUIRES -Version 2.0
 <#
 Last Modified: 11-Apr-2017
 Usage:			Enable/Disable Firewall in different profile
 Example:		firewall.ps1 -Action on -Profile allprofiles
 Explanation:	Profile Type allprofiles, currentprofile, domainprofile, privateprofile, publicprofile
 Note:			This powershell cannot override settings on domain group policy
 #>
 param(
[Parameter(Mandatory=$true)][string]$Action,
[Parameter(Mandatory=$true)][string]$Profile
)
if("on","off" -NotContains $Action)
{
echo "Invalid Action Specifed"
}
else
{
if("allprofiles", "currentprofile", "domainprofile", "privateprofile", "publicprofile" -NotContains $Profile)
{
echo "Invalid profile Specifed"
}
else
{
netsh advfirewall set $Profile state $Action
}
}