

SharePoint Web Services Default

#start search services
$SearchInst = Get-SPEnterpriseSearchServiceInstance
# Stores the identity for the Search service instance on this server as a variable 
Start-SPServiceInstance $SearchInst
# Starts the service instance
#instance ID: 712f4ec9-759d-48fa-9476-7818e1c263a6

#Secure Store Service Application
$applicationPool = Get-SPServiceApplicationPool -Identity 'SharePoint Web Services default'
$sss = New-SPSecureStoreServiceApplication -Name 'Secure Store' -ApplicationPool $applicationPool -DatabaseName 'Secure_Store_Service_DB_fd9dfdc2-1d09-48e7-89d8-75a6444f6af0' -AuditingEnabled
#create a proxy for the Secure Store service application
$sssp = New-SPSecureStoreServiceApplicationProxy -Name SecureStoreProxy -ServiceApplication $sss -DefaultProxyGroup
#restore the passphrase for the Secure Store service application
Update-SPSecureStoreApplicationServerKey -Passphrase 2FJlsXghEas5vdJJKEXXwWFab -ServiceApplicationProxy $sssp

#Upgrade the Business Data Connectivity service application
$applicationPool = Get-SPServiceApplicationPool -Identity 'SharePoint Web Services default'
#upgrade the Business Data Connectivity service application
New-SPBusinessDataCatalogServiceApplication -Name 'BDC Service' -ApplicationPool $applicationPool -DatabaseName 'Bdc_Service_DB_fe9763f6c71c4c1284423a9ac3cca9ed'

#Upgrade the Managed Metadata service application
$applicationPool = Get-SPServiceApplicationPool -Identity 'SharePoint Web Services default'
#upgrade the Managed Metadata service application
$mms = New-SPMetadataServiceApplication -Name 'Managed Metadata Service Application' -ApplicationPool $applicationPool -DatabaseName 'Managed Metadata Service_76f890000c594bb48632f654b39c009e'
#create a proxy for the Managed Metadata service application
New-SPMetadataServiceApplicationProxy -Name 'ManagedMetadataServiceProxy' -ServiceApplication $mms -DefaultProxyGroup

#Upgrade the PerformancePoint Services service application
$applicationPool = Get-SPServiceApplicationPool -Identity 'SharePoint Web Services Default'
#upgrade the PerformancePoint Services service application
$pps = New-SPPerformancePointServiceApplication -Name 'PerformancePoint Service' -ApplicationPool $applicationPool -DatabaseName 'PerformancePoint Service Application_3e8ad7902b8f4a2498ba1c352b0d1700'
#create a proxy for the PerformancePoint Services service application
New-SPPerformancePointServiceApplicationProxy -Name 'PerfomancePointProxy' -ServiceApplication $pps -Default

#Upgrade the User Profile service application
$applicationPool = Get-SPServiceApplicationPool -Identity 'SharePoint Web Services default'
#restore the User Profile service application and upgrade the Profile and Social databases
New-SPProfileServiceApplication -Name 'UserProfileApplicationName' -ApplicationPool $applicationPool -ProfileDBName 'User Profile Service Application_ProfileDB_85f5a3aef596446aba049b337d00c70e' -SocialDBName 'User Profile Service Application_SocialDB_90ada6afa1b24b73b2ff6b5872ed12a5' -ProfileSyncDBName 'User Profile Service Application_SyncDB_d9e306db-223d-4856-a76b-3387c1e24dce'
#Create the User Profile service application proxy 
#Type the following command to get the ID for the User Profile service application and store it as a variable:
$sa = Get-SPServiceApplication | ?{$_.TypeName -eq 'User Profile Service Application'}
#Type the following command to create a proxy for the User Profile service application:
New-SPProfileServiceApplicationProxy -Name 'UserProfileServiceApplicationProxy' -ServiceApplication $sa
#Type the following command to get the Search service application proxy ID for the proxy you just created and set it as the variable $ssap:
$proxy = Get-SPServiceApplicationProxy | ?{$_.TypeName -eq 'User Profile Service Application Proxy'}
#Type the following command to add the User Profile service application proxy to the default proxy group:
#Add-SPServiceApplicationProxyGroupMember -member $proxy -id '8c0dcaf8-11ac-474c-9166-80d61b5b237a'
Add-SPServiceApplicationProxyGroupMember -member $proxy -identity ""

#Upgrade the Search service application
#Set the Search Administration database to read-only. In the second phase of the process to upgrade SharePoint Server 2013 with Service Pack 1 (SP1) data and sites to SharePoint Server 2016, you set all the other databases to read-only. Follow the same instructions now for the Search Administration database
$ssa = Get-SPEnterpriseSearchServiceApplication "Search Service Application 1"
Suspend-SPEnterpriseSearchServiceApplication -Identity $ssa
#store the application pool
$applicationPool = Get-SPServiceApplicationPool -Identity 'SharePoint Web Services default'
#restore the Search service application and upgrade the Search Administration database
$searchInst = Get-SPEnterpriseSearchServiceInstance -local
# Gets the Search service instance and sets a variable to use in the next command
Restore-SPEnterpriseSearchServiceApplication -Name 'Search Service Application 1' -applicationpool $applicationPool -databasename 'Search_Service_Application_1_DB_3955f03987434f2b8d661d42e2382374' -databaseserver CNTV-01SFDB01 -AdminSearchServiceInstance $searchInst

#Create the Search service application proxy and add it to the default proxy group by completing these actions
$ssa = Get-SPEnterpriseSearchServiceApplication
#create a proxy for the Search service application:
New-SPEnterpriseSearchServiceApplicationProxy -Name SearchProxy -SearchApplication $ssa
#get the Search service application proxy ID for the proxy you just created and set it as the variable $ssap
$ssap = Get-SPEnterpriseSearchServiceApplicationProxy
#add the Search service application proxy to the default proxy group
Add-SPServiceApplicationProxyGroupMember -member $ssap -identity ""
#Resume the Search service application in the SharePoint Server 2013
$ssa = Get-SPEnterpriseSearchServiceApplication "Search Service Application 1"
$ssa.Resume()

#Verify that all of the new proxies are in the default proxy group
$pg = Get-SPServiceApplicationProxyGroup -Identity ""
$pg.Proxies


#Attach a content database to a web application and upgrade the database
Mount-SPContentDatabase -Name WSS_CONTENT_MNGE -DatabaseServer CNTV-01SFDB01 -WebApplication http://cnc-sharepoint

#view upgrade status
Get-SPContentDatabase | ft Name, NeedsUpgradeIncludeChildren


####upgrade failure error
#Feature (Id = [75a0fea7-12fe-4cad-a1b2-525fa776c07e]) is referenced in 
#######

$Database = Get-SPContentDatabase -Identity "WSS_CONTENT_BIZPORTAL" $Database.RefreshSitesInConfigurationDatabase()
$db = Get-SPContentDatabase "WSS_CONTENT_BIZPORTAL" ;$db.RefreshSitesInConfigurationDatabase();

Test-SpContentDatabase -name "WSS_CONTENT_BIZPORTAL" -webapplication https://CNC-SharePoint -ServerInstance "CNTV-01SFDB01" > Result.txt

New-SPWebApplication -Name "SP2016_Classic" - ApplicationPool "SP2016_ClassicAppPool" - AuthenticationMethod "Kerberos" - ApplicationPoolAccount "AzureAD\farmaccount" - Port 25000 - URLhttp: //SP2016Classic
##### 
Upgrade-SPContentDatabase "WSS_CONTENT_BIZPORTAL" -SkipIntegrityChecks
New-SPWebApplication -Name “CNC-Sharepoint” -ApplicationPool “CNC-SharePoint - 80” -ApplicationPoolAccount “creeknation\mnge.spfarm” -Port 80 -URL “https://cnc-sharepoint” -AuthenticationProvider $ap -SecureSocketsLayer

Mount-SPContentDatabase -Name WSS_CONTENT_BIZPORTAL -DatabaseServer CNTV-01SFDB01 -WebApplication http://cnc-sharepoint

#Convert to claims
$ap = New-SPAuthenticationProvider -UseWindowsIntegratedAuthentication -DisableKerberos
New-SPWebApplication -name "ClaimsWebApp" -Port 80 -ApplicationPool "ClaimsAuthAppPool" -ApplicationPoolAccount (Get-SPManagedAccount "<domainname>\<user>") -AuthenticationMethod NTLM -AuthenticationProvider $ap

#test to fix auth #####################################################
$ap = New-SPAuthenticationProvider -UseWindowsIntegratedAuthentication -DisableKerberos

New-SPWebApplication -Name “CNC-Sharepoint” -ApplicationPool “CNC-SharePoint - 443” -ApplicationPoolAccount “creeknation\mnge.spfarm” -Port 443 -URL “https://cnc-sharepoint” -AuthenticationProvider $ap -SecureSocketsLayer

Mount-SPContentDatabase -Name WSS_CONTENT_MNGE -DatabaseServer CNTV-01SFDB01 -WebApplication https://cnc-sharepoint


###Dont know
Convert-SPWebApplication -Identity <yourWebAppUrl> -From Legacy -To Claims -RetainPermissions [-Force]


Get-SPAuthenticationProvider -WebApplication https://cnc-sharepoint -Zone Default
#Convert SharePoint 2013 classic-mode web applications to claims-based web applications
New-SPWebApplication -Name <Name> -ApplicationPool "ClaimsAuthAppPool" -AuthenticationMethod Kerberos -ApplicationPoolAccount "creeknation\mnge.spfarm" -Port 80 -URL http://cnc-sharepoint
Convert-SPWebApplication -Identity "http://cnc-sharepoint2:443" -From Legacy -To Claims -RetainPermissions [-Force]


#sp-site health 
Test-SPSite -Identity cd839b0d-[9707-4950-8fac-f306cb920f6c]
Repair-SPSite -Identity cd839b0d-[9707-4950-8fac-f306cb920f6c]

$wa=Get-SPWebApplication http://cnc-sharepoint
# Stores the web application at that URL as a variable 
$wa.CompatibilityRange
# Returns the CompatibilityRange for the specified web application


#move collection to another database
Move-SPSite http://cnc-sharepoint/ -DestinationDatabase WSS_CONTENT_MNGE