 #REQUIRES -Version 2.0
 <#
 Last Modified: 10-Apr-2017
 Usage:			Query NetRoute
 Example:		route_info.ps1 -key 172.20.1.
 Explanation:	Query Existing route table with entry 172.20.1.		
 #>
 
param(
[string]$key
)

if($key -eq "")
{
Get-NetRoute
}
else
{
$key = $key -replace "\.", "\."
Get-NetRoute | findstr -I $key
}
