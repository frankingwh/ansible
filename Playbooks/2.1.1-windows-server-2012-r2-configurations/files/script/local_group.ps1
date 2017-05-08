 #REQUIRES -Version 2.0
 <#
 Last Modified: 11-Apr-2017
 Usage:			Query/Add/Remove/Modify Local Group
 Example:		local_group.ps1 -Action query
 Explanation:	Query All local users
 #>
 param(
[Parameter(Mandatory=$true)][string]$Action,
[Parameter(Mandatory=$true)][string]$Groupname,
[string]$Username
)

if("query","new","remove","modify" -NotContains $Action)
{
throw("Not defined action")
return
}

if($Action -eq "query")
{
Get-LocalGroup
}

if($Action -eq "new")
{
Get-LocalGroup -Name $Groupname 2> check_group.txt
$stderr = Get-Content check_user.txt
if($stderr -like "*Get-LocalGroup : Group*was not found.")
{

}
}
