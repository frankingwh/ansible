 #REQUIRES -Version 2.0
 <#
 Last Modified: 11-Apr-2017
 Usage:			Set/Get systemlocale
 Example:		system_locale.ps1 -CultureInfo en-US
 Explanation:	Set the System Locale to en-US, requires restart
 Example:		system_local.ps1
 Note:			Get the Current System Locale
 #>
 param(
[string]$CultureInfo
)

if($CultureInfo -eq "")
{
Get-WinSystemLocale
}
else
{
Set-WinSystemLocale $CultureInfo
}