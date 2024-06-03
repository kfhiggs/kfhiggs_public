#BCD Service
$ZZBCD = "Bdc_Service_DB_fe9763f6c71c4c1284423a9ac3cca9ed"
New-SPBusinessDataCatalogServiceApplication -Name 'BDC Service' -ApplicationPool $applicationPool -DatabaseName '$ZZBDC'

#Managed Meta Data Service
$ZZMMS = "Managed Metadata Service_76f890000c594bb48632f654b39c009e"
$applicationPool = Get-SPServiceApplicationPool -Identity 'SharePoint Web Services Upgrade'
$mms = New-SPMetadataServiceApplication -Name 'Managed Metadata Service Application' -ApplicationPool $applicationPool -DatabaseName '$ZZMMS'

New-SPMetadataServiceApplicationProxy -Name MMDS_Proxy -ServiceApplication $mms -DefaultProxyGroup

#User Profile Servce
#variable for where to apply the webapp
$applicationPool = Get-SPServiceApplicationPool -Identity 'SharePoint Web Services Upgrade'
#Variables for User Profile DBs
$ZZUPSA = "User Profile Service Application_SocialDB_90ada6afa1b24b73b2ff6b5872ed12a5"
$ZZUPSP = "User Profile Service Application_ProfileDB_85f5a3aef596446aba049b337d00c70e"
#adds and configures webapp and proxy based on existing Database in SQL
$upa = New-SPProfileServiceApplication -Name 'User Profile Service Application' -ApplicationPool $applicationPool -ProfileDBName '$ZZUPSP' -SocialDBName '$ZZUPSA' 
#creates proxy service for web app
New-SPProfileServiceApplicationProxy -Name UserProfiles_Proxy -ServiceApplication $upa -DefaultProxyGroup

<######### IMPORTANT!!!!! ####### 
Need to run MIISKMU on New Farm App Server
Raw cmdlet = 
MIISKMU /e filename [/u:username {password | *}]
Used in Prod = 
CD "C:\Program Files\Microsoft Office Servers\15.0\Synchronization Service\Bin\"
.\miiskmu.exe /i "C:\Temp\miiskeys-2.bin" {0E19E162-827E-4077-82D4-E6ABD531636E}
#>

