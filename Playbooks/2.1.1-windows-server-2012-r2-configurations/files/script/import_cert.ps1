 #REQUIRES -Version 2.0
 <#
 Last Modified: 11-Apr-2017
 Usage:			Import Certficaite to IIS
 Example:		import_cert.ps1 -certPath "C:\\Deployment\\private_cert.pfx" -pfxPass Testing
 Explanation:	Import Certficaite to IIS Manager
 #>

param(
[Parameter(Mandatory=$true)][string]$certPath,
[string]$pfxPass
)
$certRootStore = "LocalMachine"
$certStore = "My"
$pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2 
$pfxPass_tmp = ConvertTo-SecureString $pfxPass -AsPlainText -Force
$pfx.import($certPath,$pfxPass_tmp,"Exportable,PersistKeySet")
$store = new-object System.Security.Cryptography.X509Certificates.X509Store($certStore,$certRootStore)
$store.open("MaxAllowed")
$store.add($pfx)
$store.close()