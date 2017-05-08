 #REQUIRES -Version 2.0
 <#
 Last Modified: 10-Apr-2017
 Usage:			Add NetRoute
 Example:		route_add.ps1 -Destination "10.0.0.0/24" -NextHop 192.168.0.1
 Explanation:	Add a new route to 10.0.0.0/24 subnet with next hop 192.168.0.1	
 #>
 
param(
[Parameter(Mandatory=$true)][string]$Destination,
[Parameter(Mandatory=$true)][string]$NextHop
)
$Index = Find-NetRoute -RemoteIPAddress "8.8.8.8" | select -first 1  -expandproperty interfaceindex
New-NetRoute -DestinationPrefix $Destination -NextHop $NextHop -InterfaceIndex $Index