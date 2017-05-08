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
[string]$Password,
[string]$FullName
)
if("query","new","remove","modify" -NotContains $Action)
{
throw("Not defined action")
return
}

if($Action -eq "query")
{
Get-LocalUser
}

if($Action -eq "new")
{
Get-LocalUser -Name $Username 2> check_user.txt
$stderr = Get-Content check_user.txt
Remove-Item check_user.txt
if($stderr -like "*Get-LocalUser : User*was not found.")
{
if($Username -ne "")
{
if($Password -ne "")
{
$Secure_String_Pwd = ConvertTo-SecureString $Password -AsPlainText -Force
if($FullName -ne "")
{
New-LocalUser $Username -Password $Secure_String_Pwd -FullName $FullName
}
else
{
New-LocalUser $Username -Password $Secure_String_Pwd
}
}
else
{
throw("Password is empty")
}
}
else
{
throw("Username is empty")
}
}
else
{
throw("User already exist!")
}
}

if($Action -eq "remove")
{
Get-LocalUser -Name $Username 2> check_user.txt
$stderr = Get-Content check_user.txt
if($stderr -like "*Get-LocalUser : User*was not found.")
{
throw("User cannot be find in the list")
}
else
{
Remove-LocalUser -Name $Username
}
}

if($Action -eq "modify")
{
Get-LocalUser -Name $Username 2> check_user.txt
$stderr = Get-Content check_user.txt
if($stderr -like "*Get-LocalUser : User*was not found.")
{
throw("User cannot be find in the list")
}
else
{
if($Password -ne "")
{
$Secure_String_Pwd = ConvertTo-SecureString $Password -AsPlainText -Force
Set-LocalUser -Name $Username -Password $Secure_String_Pwd
echo "Password Modified"
}
}
}