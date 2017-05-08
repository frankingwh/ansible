 #REQUIRES -Version 2.0
 <#
 Last Modified: 11-Apr-2017
 Usage:			Import security template located in Deployment folder
 Example:		security_template.ps1
 #>

param(
[Parameter(Mandatory=$true)][string]$templatefile
)
cd c:\psscript
secedit /configure /db sectemplate.sdb /cfg $templatefile /log change.log