Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'PSModule Installer'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,120)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,30)
$label.Text = 'Please enter the name of a PowerShell Module in the space below:'
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,50)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)

$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $textBox.Text
}

$custommod = $x
if (!(get-module $custommod -listavailable)) {
    Write-Output "Installing $custommod"
    if (Find-Module $custommod){
        Install-Module $custommod -Scope CurrentUser -Force
        Add-Type -AssemblyName PresentationCore,PresentationFramework
        $msgBody = "$custommod module successfully Installed"
        [System.Windows.MessageBox]::Show($msgBody)
    }
    else {
        Add-Type -AssemblyName PresentationCore,PresentationFramework
        $msgBody = "$custommod not found in repository, verify module name"
        [System.Windows.MessageBox]::Show($msgBody)    
    }
}
else {
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $msgBody = "$custommod module is already Installed"
    [System.Windows.MessageBox]::Show($msgBody)
}