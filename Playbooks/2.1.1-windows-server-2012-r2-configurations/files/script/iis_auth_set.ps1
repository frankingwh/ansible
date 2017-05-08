param(
[Parameter(Mandatory=$true)][string]$Auth,
[Parameter(Mandatory=$true)][string]$Value,
[Parameter(Mandatory=$true)][string]$Location
)

if("anonymousAuthentication","windowsAuthentication" -NotContains $Auth)
{
throw("Not defined Auth Type")
return
}

if($Value -eq "true")
{
Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/$Auth" -name enabled -value true -PSPath "IIS:\" -Location $Location
}


if($Value -eq "false")
{
Set-WebConfigurationProperty -filter "/system.webServer/security/authentication/$Auth" -name enabled -value false -PSPath "IIS:\" -Location $Location
}