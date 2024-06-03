#defines powershell objects of available modules
$InstModules = (Get-Module -ListAvailable)

#defines selection box
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Higgs Module Uninstaller'
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
$label.Text = 'Choose the Module to uninstall:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)

$listBox.SelectionMode = 'MultiExtended'

$listBox.Height = 70
$form.Controls.Add($listBox)
$form.Topmost = $true


#function to create array of modules names and put them in selection box
foreach ($mod in $InstModules.name) {
    [void] $listBox.Items.Add("$mod")
} 
#Shows dialog box
$result = $form.ShowDialog()
#variable $x devines box selections
if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $listBox.SelectedItems
}
#defines action to be performed on each $x as an array for each
foreach ($term in $x) {
    $oldverbose = $VerbosePreference
    $VerbosePreference = "continue"
    Uninstall-Module $term -Force
    Write-Verbose "Module Uninstalled"
} 
$VerbosePreference = $oldverbose