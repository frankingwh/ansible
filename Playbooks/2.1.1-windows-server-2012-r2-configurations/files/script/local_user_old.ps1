 #REQUIRES -Version 2.0
 <#
 Last Modified: 11-Apr-2017
 Usage:			Query/Add/Remove/Modify Local User account
 Example:		local_user.ps1 -Action query
 Explanation:	Query All local users
 Usage:			local_user.ps1 -Action new -Username test -Password Testing@#
 Explanation:	Add a new user with username test and password Testing
 Notes:			Don't forget to match the complexity for the password!
 Usage:			local_user.ps1 -Action remove -Username test
 Explanation:	Remove a local user with username test
 Usage:			local_user.ps1 -Action modify -Username test -Password Testing@#$
 Explanation:	Modify the password to new password Testing@#$
 #>
 param(
[Parameter(Mandatory=$true)][string]$Action,
[Parameter(Mandatory=$true)][string]$Username,
[string]$Password
)

if("query","new","remove","modify" -NotContains $Action)
{
throw("Not defined action")
return
}

if($Action -eq "query")
{
net user
}

if($Action -eq "new")
{
net user $Username $Password /add
}

if($Action -eq "remove")
{
net user $Username /delete
}

if($Action -eq "modify")
{
net user $Username $Password /add
}