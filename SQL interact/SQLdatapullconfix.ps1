#Following lines edit the config for machines exiting in CVPS devices
#query database and export results as an array
$server = 'SERVERHOSTNAME'
$computer = "$env:COMPUTERNAME"
$query = @(Invoke-Sqlcmd -query "select XXQueryXX1, XXQueryXX2, XXQueryXX3 FROM [ivaletparc].[syst].[Devices] WHERE DeviceName = '$computer'" -server $server)

#functions for modifying conf files
function mainConf {
    $conf = "C:\CONFIGFILELOCATION.Config"
    #open file as xml object
    $xml = [xml](Get-Content $conf)
    #modify attributes within xml object
    #change 'appsettingskey' to what you need changed pulled from above
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'APPSETTINGSKEY1' }).value = [string]($query.XXQueryXX1)
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'APPSETTINGSKEY2' }).value = [string]($query.XXQueryXX2)
    #save object back to file
    $xml.Save($conf)
}

#if required values aren't null, run functions to modify conf files.
if ([bool]([string]($query.DeviceID))) {
    mainConf
}
else {
    $a = new-object -comobject wscript.shell
$a.popup("Machine not in database.", 0, "Error")
}