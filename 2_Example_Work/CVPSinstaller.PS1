
#Created by Kenneth Higgs 03/29/2022
#Updated by Kenneth Higgs 05/15/2024
###############################################################
#Install SQL server2
###############################################################
#Required to run the invoke-SQLcmd
if(-not (Get-Module SQLserver -ListAvailable)){
    Install-Module SQLserver -Scope CurrentUser -Force
}
else {
    $oldverbose = $VerbosePreference
    $VerbosePreference = "continue"
    Write-Verbose "SQLserver is already installed."
}
$VerbosePreference = $oldverbose
###############################################################
#choice box for workstation location
###############################################################
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = 'CVPS Basic Installer'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Choose the workstation location:'
$form.Controls.Add($label)
$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)
$listBox.SelectionMode = 'MultiExtended'
[void] $listBox.Items.Add('Hotel')
[void] $listBox.Items.Add('Casino')
[void] $listBox.Items.Add('Dispatch')
[void] $listBox.Items.Add('STSARDScanner')
[void] $listBox.Items.Add('STSFrontScanner')
$listBox.Height = 70
$form.Controls.Add($listBox)
$form.Topmost = $true
$result = $form.ShowDialog()
if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $locchoice = $listBox.SelectedItems
    $locchoice
}
###############################################################
#Below are variables used in the script
###############################################################
#destination file folder for main CVPS program files
$destination = "C:\Program Files\cvpsNET"

#unc path for main CVPS program files
$source = "\\cntv-01cvap02\CVPS Support\LIVE Update .142\cvpsNET"

#Public Desktop folder
$dtpub = "C:\Users\Public\Desktop"

#Startup Folder
$comstartup = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"

#Source STSard program files
$source1 = "\\cntv-01cvap02\CVPS Support\LIVE Update .142\STSARDScanner"

#Source STSfront program files
$source2 = "\\cntv-01cvap02\CVPS Support\LIVE Update .142\STSFrontScanner"

#Destination for STSardScanner program files
$destination1 = "C:\Program Files\STSARDScanner"

#Destination for STSfrontScanner program files
$destination2 = "C:\Program Files\STSFrontScanner"

#link files used for starup and desktop with presaved target switches
$CVnet = "C:\Program Files\cvpsNET\CVPSnet.lnk"
$CVnetmon = "C:\Program Files\cvpsNET\CVPS RequestMonitor.lnk"
$CVnetstage = "C:\Program Files\cvpsNET\CVPS RequestMonitor Staging.lnk"
$CVnetpark = "C:\Program Files\cvpsNET\CVPS RequestMonitor Parking.lnk"
$CVnetkey = "C:\Program Files\cvpsNET\CVPS RequestMonitor Key.lnk"

#link to Database connector cmd file which kicks off PS at startup to replace the DBconnection string file
$CVnetDB = "C:\Program Files\cvpsNET\DBconnectorStartup.cmd"

#STS scanner startup links
$stsardstart = "C:\Program Files\STSARDScanner\STSARDScanner.exe.lnk"
$stsfrontstart = "C:\Program Files\STSFrontScanner\STSFrontScanner.exe.lnk"
###############################################################
#Below are functions used in the script
###############################################################
#Copy program files from CNTV-01CVAP02
#This copies all the source files from the CVPS app server to local machine
#Show progress bar
Function global:instcorecvps {
    if (!(test-path $destination)) {
        New-Item -ItemType Directory -Path $destination -Force
    }
    $files = get-childitem $source
    $bump = [int]100 / $files.count
    $i = $bump
    foreach ($file in $files) {
        $perc = [Math]::Truncate($i)
        Write-Progress -Activity "Copying $file" -Status "$perc% Complete:" -PercentComplete $i
        Copy-Item $($file.fullname) ($($file.fullname) -replace [regex]::Escape($source), $destination) -recurse -force
        $i = $i + $bump
    } 
    pfaccess
    pfreader
    configdata
}
Function global:instard {
    if (!(test-path $destination1)) {
        New-Item -ItemType Directory -Path $destination1 -Force
    }
    $files = get-childitem $source1
    $bump = [int]100 / $files.count
    $i = $bump
    foreach ($file in $files) {
        $perc = [Math]::Truncate($i)
        Write-Progress -Activity "Copying $file" -Status "$perc% Complete:" -PercentComplete $i
        Copy-Item $($file.fullname) ($($file.fullname) -replace [regex]::Escape($source1), $destination1) -recurse -force
        $i = $i + $bump
    } 
    icacls $destination1 /grant "Everyone:(OI)(CI)F" /T
    Get-ChildItem -Path $destination1 -Recurse -File | ForEach-Object { $_.IsReadOnly=$False }
}
Function global:instfront {
    if (!(test-path $destination2)) {
        New-Item -ItemType Directory -Path $destination2 -Force
    }
    $files = get-childitem $source2
    $bump = [int]100 / $files.count
    $i = $bump
    foreach ($file in $files) {
        $perc = [Math]::Truncate($i)
        Write-Progress -Activity "Copying $file" -Status "$perc% Complete:" -PercentComplete $i
        Copy-Item $($file.fullname) ($($file.fullname) -replace [regex]::Escape($source2), $destination2) -recurse -force
        $i = $i + $bump
    } 
        icacls $destination2 /grant "Everyone:(OI)(CI)F" /T
        Get-ChildItem -Path $destination2 -Recurse -File | ForEach-Object { $_.IsReadOnly=$False }
}
Function global:pfaccess {
    icacls $destination /grant "Everyone:(OI)(CI)F" /T
}
Function global:pfreader {
    Get-ChildItem -Path $destination -Recurse -File | ForEach-Object { $_.IsReadOnly=$False }
}
#this switch triggers modify function if machine is present in DB
#if required values aren't null, run functions to modify conf files.

###############################################################

#these functions modify Device ID, Mac address and monitor types
#Following lines edit the config for machines exiting in CVPS devices
#query database and export results as an array
$server = 'cntv-01cvdb02'
$computer = "$env:COMPUTERNAME"
$query = @(Invoke-Sqlcmd -query "select DeviceID, DeviceName, MAC FROM [ivaletparc].[syst].[Devices] WHERE DeviceName = '$computer'" -server $server)
#functions for modifying conf files
function mainConf {
    $conf = "C:\Program Files\cvpsNET\Bin\CVPSnet.exe.Config"
    #open file as xml object
    $xml = [xml](Get-Content $conf)
    #modify attributes within xml object
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'DeviceID' }).value = [string]($query.DeviceID)
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'MAC' }).value = [string]($query.MAC)
    #save object back to file
    $xml.Save($conf)
}
#Request monitor config
function reqConf {
    $conf = "C:\Program Files\cvpsNET\RequestMonitor\Bin\CVPS_RequestMonitor.exe.Config"
    #open file as xml object
    $xml = [xml](Get-Content $conf)
    #modify attributes within xml object
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'DeviceID' }).value = [string]($query.DeviceID)
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'MAC' }).value = [string]($query.MAC)
    #save object back to file
    $xml.Save($conf)
}
#staging monitor config
function stagingConf {
    $conf = "C:\Program Files\cvpsNET\RequestMonitor_Staging\Bin\CVPS_RequestMonitor.exe.Config"
    #open file as xml object
    $xml = [xml](Get-Content $conf)
    #modify attributes within xml object
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'DeviceID' }).value = [string]($query.DeviceID)
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'MAC' }).value = [string]($query.MAC)
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'MonitorType' }).value = "Staging"
    #save object back to file
    $xml.Save($conf)
}
#parking monitor config
function parkingConf {
    $conf = "C:\Program Files\cvpsNET\RequestMonitor_Parking\Bin\CVPS_RequestMonitor.exe.Config"
    #open file as xml object
    $xml = [xml](Get-Content $conf)
    #modify attributes within xml object
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'DeviceID' }).value = [string]($query.DeviceID)
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'MAC' }).value = [string]($query.MAC)
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'MonitorType' }).value = "Parking"
    #save object back to file
    $xml.Save($conf)
}
#key drop monitor config
function keyConf {
    $conf = "C:\Program Files\cvpsNET\RequestMonitor_key\Bin\CVPS_RequestMonitor.exe.Config"
    #open file as xml object
    $xml = [xml](Get-Content $conf)
    #modify attributes within xml object
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'DeviceID' }).value = [string]($query.DeviceID)
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'MAC' }).value = [string]($query.MAC)
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'MonitorType' }).value = "Key"
    #save object back to file
    $xml.Save($conf)
}
Function configdata {
    if ([bool]([string]($query.DeviceID))) {
        mainConf
        reqConf
        stagingConf
        parkingConf
        keyConf
    }
    else {
        $a = new-object -comobject wscript.shell
    $a.popup("Machine not in database, please add machine in CVPS.", 0, "Error")
    }
    }

#At this point all configs should have the correct Device ID and Mac based on what is in the database
    
###############################################################
#Location ID Functions
#Sets default location as hotel
function hotelloc {
    $conf = "C:\Program Files\cvpsNET\Bin\CVPSnet.exe.Config"
    #open file as xml object
    $xml = [xml](Get-Content $conf)
    #modify attributes within xml object
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'Default Location' }).value = "1"
    #save object back to file
    $xml.Save($conf)
}
#Sets default location as Casino
function casinoloc {
    $conf = "C:\Program Files\cvpsNET\Bin\CVPSnet.exe.Config"
    #open file as xml object
    $xml = [xml](Get-Content $conf)
    #modify attributes within xml object
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'Default Location' }).value = "2"
    #save object back to file
    $xml.Save($conf)
}
#Sets default location as Dispatch
function dispatchloc {
    $conf = "C:\Program Files\cvpsNET\Bin\CVPSnet.exe.Config"
    #open file as xml object
    $xml = [xml](Get-Content $conf)
    #modify attributes within xml object
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'Default Location' }).value = "3"
    #save object back to file
    $xml.Save($conf)
}
#Sets default location as STSardScanner(same as dispatch)
function ardloc {
    $conf = "C:\Program Files\STSARDScanner\STSARDScanner.exe.config"
    #open file as xml object
    $xml = [xml](Get-Content $conf)
    #modify attributes within xml object
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'Default Location' }).value = "3"
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'ARDScannerCOMPort' }).value = "5"
    #save object back to file
    $xml.Save($conf)
}
#Sets default location as STSfrontScanner(same as dispatch)
function frontloc {
    $conf = "C:\Program Files\STSFrontScanner\STSFrontScanner.exe.config"
    #open file as xml object
    $xml = [xml](Get-Content $conf)
    #modify attributes within xml object
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'Default Location' }).value = "3"
    ($xml.configuration.appSettings.add | where-object { $_.key -eq 'FrontScannerCOMPort' }).value = "4"
    #save object back to file
    $xml.Save($conf)
}
###############################################################
#startup folder functions for adding auto startup
function hotelstartup {
    Copy-Item $CVnet -Destination $comstartup
    Copy-Item $CVnetmon -Destination $comstartup
    #This copies the DBconnector to Startup folder to recurse the DBConnectionString on startup
    Copy-Item $CVnetDB -Destination $comstartup
    #This copies all shortcuts to the public desktop
    Copy-Item $CVnet -Destination $dtpub
    Copy-Item $CVnetmon -Destination $dtpub
    Copy-Item $CVnetstage -Destination $dtpub
    Copy-Item $CVnetkey -Destination $dtpub
    Copy-Item $CVnetpark -Destination $dtpub
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $msgBody = "Computer successfully configured for Hotel, please verify icons on desktop and startup items by having a user login"
    [System.Windows.MessageBox]::Show($msgBody)
}
function casinostartup {
    Copy-Item $CVnet -Destination $comstartup
    Copy-Item $CVnetmon -Destination $comstartup
    #This copies the DBconnector to Startup folder to recurse the DBConnectionString on startup
    Copy-Item $CVnetDB -Destination $comstartup
    #This copies all shortcuts to the public desktop
    Copy-Item $CVnet -Destination $dtpub
    Copy-Item $CVnetmon -Destination $dtpub
    Copy-Item $CVnetstage -Destination $dtpub
    Copy-Item $CVnetkey -Destination $dtpub
    Copy-Item $CVnetpark -Destination $dtpub
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $msgBody = "Computer successfully configured for Casino, please verify icons on desktop and startup items by having a user login"
    [System.Windows.MessageBox]::Show($msgBody)
}
function dispatchstartup {
    Copy-Item $CVnet -Destination $comstartup
    Copy-Item $CVnetmon -Destination $comstartup
    Copy-Item $CVnetstage -Destination $comstartup
    Copy-Item $CVnetpark -Destination $comstartup
    Copy-Item $CVnetkey -Destination $comstartup
    #This copies the DBconnector to Startup folder to recurse the DBConnectionString on startup
    Copy-Item $CVnetDB -Destination $comstartup
    #This copies all shortcuts to the public desktop
    Copy-Item $CVnet -Destination $dtpub
    Copy-Item $CVnetmon -Destination $dtpub
    Copy-Item $CVnetstage -Destination $dtpub
    Copy-Item $CVnetkey -Destination $dtpub
    Copy-Item $CVnetpark -Destination $dtpub
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $msgBody = "Computer successfully configured for Dispatch, please verify icons on desktop and startup items by having a user login"
    [System.Windows.MessageBox]::Show($msgBody)
}
function ardstartup {
    Copy-Item $stsardstart -Destination $comstartup
    Copy-Item $stsardstart -Destination $dtpub
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $msgBody = "STS ARD Scanner successfully added, please verify the scanner's comm port is set to 5 and change it if to 5 if needed"
    [System.Windows.MessageBox]::Show($msgBody)
}
function frontstartup {
    Copy-Item $stsfrontstart -Destination $comstartup
    Copy-Item $stsfrontstart -Destination $dtpub
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $msgBody = "STS Front Scanner successfully added, please verify the scanner's comm port is set to 4 and change it if to 4 if needed"
    [System.Windows.MessageBox]::Show($msgBody)
}
###############################################################
#Switch Statements
###############################################################
#this switch triggers install move of folders to local destination
Switch ($locchoice)
{
    Hotel { $result1 = global:instcorecvps }
    Casino { $result1 = global:instcorecvps }
    Dispatch { $result1 = global:instcorecvps }
    STSARDScanner { $result1 = global:instard }
    STSFrontScanner { $result1 = global:instfront }
}
$result1
###############################################################>
#this switch trigers location ID functions
#Sets the Default location ID in the config file
switch ($locchoice)
{
    Hotel { $result2 = hotelloc }
    Casino { $result2 = casinoloc }
    Dispatch { $result2 = dispatchloc }
    STSARDScanner { $result2 = ardloc }
    STSFrontScanner { $result2 = frontloc }
}
$result2
###############################################################
#this switch sets which monitors startup by default, placing .lnks in the startup folder based on $locchoice variable
switch ($locchoice)
{
    Hotel { $result3 = hotelstartup }
    Casino { $result3 = casinostartup }
    Dispatch { $result3 = dispatchstartup }
    STSARDScanner { $result3 = ardstartup }
    STSFrontScanner { $result3 = frontstartup }
}
$result3
