 #REQUIRES -Version 2.0
 <#
 Last Modified: 11-Apr-2017
 Usage:			Remvoe Net Route
 Example:		route_del.ps1 -Destination "10.0.0.0/24" -NextHop 192.168.0.1
 Explanation:	Remove all net route which next hop is 192.168.0.1 and the network is 10.0.0.0/24
 #>
 
param(
[Parameter(Mandatory=$true)][string]$Destination,
[Parameter(Mandatory=$true)][string]$NextHop
)
Remove-NetRoute -NextHop $NextHop -DestinationPrefix $Destination -Confirm:$false 2>Route_Del.txt
if(Test-Path Route_Del.txt){
$err = get-content Route_Del.txt
Remove-Item Route_Del.txt
if($error -like '*No matching MSFT_NetRoute objects found*')
{
echo "No Matching Route Found!"
}
else
{
echo "Unknown Error, details:"
echo $err
}
}