Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

$youtubeUrl = ""
Do {
    $youtubeUrl = [Microsoft.VisualBasic.Interaction]::InputBox("Enter YouTube URL", "Watch", "")
}
While (($youtubeUrl -eq "") -or ($youtubeUrl.SubString(0,[math]::min(32,$youtubeUrl.length)) -ne 'https://www.youtube.com/watch?v='))

$WebBrowser = New-Object System.Windows.Forms.WebBrowser
$WebBrowser.Dock = [System.Windows.Forms.DockStyle]::Fill
$WebBrowser.Location = New-Object System.Drawing.Point(0, 0)
$WebBrowser.MinimumSize = New-Object System.Drawing.Size(20, 20)
$WebBrowser.ScriptErrorsSuppressed = $true
$WebBrowser.Size = New-Object System.Drawing.Size(800, 450)
$WebBrowser.TabIndex = 0
$WebBrowser.Url = New-Object System.Uri($youtubeUrl, [System.UriKind]::Absolute)

$Form = New-Object System.Windows.Forms.Form
$Form.AutoScaleDimensions = New-Object System.Drawing.SizeF(8,16)
$Form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font
$Form.ClientSize = New-Object System.Drawing.Size(1080, 420)
$Form.Controls.Add($WebBrowser)
$Form.Text = "Powertube Player"

$Form.ShowDialog()

$Form.Close()