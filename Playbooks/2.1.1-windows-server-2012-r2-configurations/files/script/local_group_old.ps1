 #REQUIRES -Version 2.0
 <#
 Last Modified: 11-Apr-2017
 Usage:			Query/Create/Remove/Modify Member of Local Group
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
net localgroup
}

if($Action -eq "new")
{
net localgroup $Groupname /add
}

if($Action -eq "remove")
{
net localgroup $Groupname /delete
}

if($Action -eq "modify")
{
net localgroup $Groupname $Username /add
}
