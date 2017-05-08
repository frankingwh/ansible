 #REQUIRES -Version 2.0
 <#
 Last Modified: 11-Apr-2017
 Usage:			Set the network adapter property, for details, please refer to MSDN Get-NetAdapterAdvancedProperty
 Example:		NIC_set.ps1 -RegistryKeyword "*JumboPacket" -Registryvalue 1514
 Explanation	Disable Jumbo frames
 
 switch ($dup.sValue) {            
 "0" {$duplex = "Auto Detect"}            
 "1" {$duplex = "10Mbps \ Half Duplex"}            
 "2" {$duplex = "10Mbps \ Full Duplex"}            
 "3" {$duplex = "100Mbps \ Half Duplex"}            
 "4" {$duplex = "100Mbps \ Full Duplex"} 
 
 #>
  param(
[Parameter(Mandatory=$true)][string]$RegistryKeyword,
[Parameter(Mandatory=$true)][string]$Registryvalue
)
 Set-NetAdapterAdvancedProperty -RegistryKeyword $RegistryKeyword -Registryvalue $Registryvalue
 Get-NetAdapterAdvancedProperty | findstr -I $RegistryKeyword 