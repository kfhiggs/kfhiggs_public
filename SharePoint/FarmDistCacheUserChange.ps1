Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
#Get the Farm
$farm = Get-SPFarm
#Get Distributed Cache Service
$cacheService = $farm.Services | where {$_.Name -eq "AppFabricCachingService"}
#Get the Managed account
$accnt = Get-SPManagedAccount -Identity creeknation\mnge.spfarm
#Set Service Account for Distributed Cache Service
$cacheService.ProcessIdentity.CurrentIdentityType = "SpecificUser"
$cacheService.ProcessIdentity.ManagedAccount = $accnt
$cacheService.ProcessIdentity.Update() 
$cacheService.ProcessIdentity.Deploy()