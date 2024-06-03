#Start search service
$SearchInst = Get-SPEnterpriseSearchServiceInstance
# Stores the identity for the Search service instance on this server as a variable 

Start-SPServiceInstance $SearchInst
# Starts the service instance

#Upgrade the Secure Store service application
$applicationPool = Get-SPServiceApplicationPool -Identity 'SharePoint Web Services default'
$sss = New-SPSecureStoreServiceApplication -Name 'Secure Store' -ApplicationPool $applicationPool -DatabaseName 'Secure_Store_Service_DB_fd9dfdc2-1d09-48e7-89d8-75a6444f6af0' -AuditingEnabled
#create proxy
$sssp = New-SPSecureStoreServiceApplicationProxy -Name SecureStoreProxy -ServiceApplication $sss -DefaultProxyGroup

#To refresh the encryption key
#On the Central Administration home page, in the Application Management section, click Manage service applications.
#Click the Secure Store service application.
#In the Key Management group, click Refresh Key.
#In the ** Pass Phrase ** box, type the pass phrase that you first used to generate the encryption key.

Update-SPSecureStoreApplicationServerKey -Passphrase 2FJlsXghEas5vdJJKEXXwWFab -ServiceApplicationProxy $sssp

#Upgrade the Business Data Connectivity service application
$applicationPool = Get-SPServiceApplicationPool -Identity 'SharePoint Web Services default'
New-SPBusinessDataCatalogServiceApplication -Name 'BDC Service' -ApplicationPool $applicationPool -DatabaseName 'Bdc_Service_DB_fe9763f6c71c4c1284423a9ac3cca9ed'

#Upgrade the Managed Metadata service application
$applicationPool = Get-SPServiceApplicationPool -Identity 'SharePoint Web Services default'
$mms = New-SPMetadataServiceApplication -Name 'Managed Metadata Service Application' -ApplicationPool $applicationPool -DatabaseName 'Managed Metadata Service_76f890000c594bb48632f654b39c009e'
#create proxy
New-SPMetadataServiceApplicationProxy -Name ManagedMetadataServiceProxy -ServiceApplication $mms -DefaultProxyGroup

#Upgrade the PerformancePoint Services service application
$applicationPool = Get-SPServiceApplicationPool -Identity 'SharePoint Web Services default'
$pps = New-SPPerformancePointServiceApplication -Name 'PerformancePoint Service' -ApplicationPool $applicationPool -DatabaseName 'PerformancePoint Service Application_3e8ad7902b8f4a2498ba1c352b0d1700'
#create proxy
New-SPPerformancePointServiceApplicationProxy -Name PerformancePointProxy -ServiceApplication $pps -Default

#upgrade the Search service application
$ssa = Get-SPEnterpriseSearchServiceApplication 'Search Service Application'
Suspend-SPEnterpriseSearchServiceApplication -Identity $ssa
#Where SearchServiceApplicationName is the name of the Search service application you want to pause.
#copy search db and move it to 2019
$applicationPool = Get-SPServiceApplicationPool -Identity 'SharePoint Web Services default'
$searchInst = Get-SPEnterpriseSearchServiceInstance -local
# Gets the Search service instance and sets a variable to use in the next command
Restore-SPEnterpriseSearchServiceApplication -Name 'Search Service Application' -applicationpool $applicationPool -databasename 'Search_Service_Application_1_DB_3955f03987434f2b8d661d42e2382374' -databaseserver cntv-01sfdb02 -AdminSearchServiceInstance $searchInst


$ssa = Get-SPEnterpriseSearchServiceApplication 'Search Service Application'
New-SPEnterpriseSearchServiceApplicationProxy -Name SearchServiceProxy -SearchApplication $ssa
$ssap = Get-SPEnterpriseSearchServiceApplicationProxy
Add-SPServiceApplicationProxyGroupMember -member $ssap -identity ""

$ssa = Get-SPEnterpriseSearchServiceApplication 'Search Service Application'
$ssa.ForceResume(0x02)

#verify new proxies
$pg = Get-SPServiceApplicationProxyGroup -Identity ""
$pg.Proxies

#Test content database
Mount-SPContentDatabase -Name WSS_CONTENT_MNGE -DatabaseServer CNTV-01SFDB02 -WebApplication https://cnc-sharepoint

Test-SPContentDatabase -Name WSS_CONTENT_MNGE -WebApplication https://cnc-sharepoint


#MOOS
#create binding
New-SPWOPIBinding -ServerName https://officeonline.creeknation.net

Get-SPWOPIZone

$Farm = Get-SPFarm
$Farm.Properties.Add("WopiLegacySoapSupport", "https://officeonline.creeknation.net/x/_vti_bin/ExcelServiceInternal.asmx");
$Farm.Update();


#sptest2019 site mount
Mount-SPContentDatabase -Name WSS_CONTENT_SPtest2019 -DatabaseServer CNTV-01SFDB02 -WebApplication https://sptest2019