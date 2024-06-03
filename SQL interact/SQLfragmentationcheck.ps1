$ServerName = 'cntv-01cvdb02'
$InstanceName = 'DEFAULT'

$DBNameList = invoke-Sqlcmd -query "                 
select HOST_NAME() AS [HOSTNAME], @@SERVICENAME AS [INSTANCENAME],name AS [DBName] 
from sys.databases 
where state = 0 and name not in ('master','tempdb','model','msdb');
" -serverinstance $ServerName
$DBNameList

$Results = @()

foreach($Name in $DBNameList)
{
$NameDB = $Name.DBName
$NameHN = $Name.HOSTNAME
$Results += Invoke-Sqlcmd -Query "
select HOST_NAME() AS [HOSTNAME], @@SERVICENAME AS [INSTANCENAME], DB_NAME(database_id) AS [DBName], SI.name AS [IndexName], SI.object_id, SDI.index_type_desc AS [IndexType], SDI.avg_fragmentation_in_percent AS [FragmentPercentage]
from sys.dm_db_index_physical_stats (db_id(),NULL,NULL,NULL,NULL) SDI
inner join sys.indexes SI
on SDI.object_id = SI.object_id
where SDI.avg_fragmentation_in_percent >30
order by SDI.avg_fragmentation_in_percent DESC
" -Database $NameDB -ServerInstance $NameHN ##\$InstanceName
}

$Results