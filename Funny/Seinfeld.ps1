Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Data Entry Form'
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
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please enter the information in the space below:'
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)

$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $textBox.Text
    $x
}
$target = $x
Copy-Item "P:\IT Techs\Patch1.0\seinfeld.wav" -Destination "\\$target\C$\windows\media\"

Enter-PSSession $target

#this will set system sound to seinfeld
$RegistryPath = 'HKCU:\AppEvents\Schemes\Apps\.Default\.Default\.Current'
$value = Get-ItemProperty -Path $RegistryPath -Name "(Default)"
$newpath = $value."(Default)" = "C:\Windows\Media\Seinfeld.wav"
Set-ItemProperty -Path $RegistryPath -Name '(Default)' -Value $newpath

<#this will change it back to normal
$RegistryPath = 'HKCU:\AppEvents\Schemes\Apps\.Default\.Default\.Current'
$value = Get-ItemProperty -Path $RegistryPath -Name "(Default)"
$newpath = $value."(Default)" = "C:\Windows\Media\Windows Background.wav"
Set-ItemProperty -Path $RegistryPath -Name '(Default)' -Value $newpath
#>