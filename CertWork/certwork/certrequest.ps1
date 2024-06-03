<#
.SYNOPSIS
  This script is a GUI Cert Requester.
  
.NOTES
  Version:         1.0
  Original Author: Kristopher Hall

  Creation Date:   08/24/2022
  Version Log:	   08/24/2022 Initial write.

#>
#Declarations

$LOC = switch (($env:computername).substring(2, 1)) {
    t { "Tulsa" }
    m { "Muskogee" }
    o { "Okmulgee" }
    default { "Tulsa" }
}

Add-Type -AssemblyName System.Windows.Forms
[void][system.reflection.assembly]::LoadWithPartialName("System.Drawing")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.Application]::EnableVisualStyles();

#form
$objForm = New-Object System.Windows.Forms.Form
$objForm.Text = "Cert Requester"
$objForm.Size = New-Object System.Drawing.Size(400, 210)
$objForm.StartPosition = "CenterScreen"
$objForm.FormBorderStyle = 'FixedDialog'

#textboxes
$CN_tb = New-Object System.Windows.Forms.TextBox
$CN_tb.Location = New-Object System.Drawing.Point(55, 20)
$CN_tb.Size = New-Object System.Drawing.Size(200, 20)
$CN_tb.multiline = $false
$CN_tb.Enabled = $false
$CN_tb.text = "$env:computername"
$objForm.Controls.Add($CN_tb)

$FN_tb = New-Object System.Windows.Forms.TextBox
$FN_tb.Location = New-Object System.Drawing.Point(55, 40)
$FN_tb.Size = New-Object System.Drawing.Size(200, 20)
$FN_tb.multiline = $false
$FN_tb.Enabled = $true
$objForm.Controls.Add($FN_tb)

$LOC_tb = New-Object System.Windows.Forms.TextBox
$LOC_tb.Location = New-Object System.Drawing.Point(55, 60)
$LOC_tb.Size = New-Object System.Drawing.Size(200, 20)
$LOC_tb.multiline = $false
$LOC_tb.Enabled = $false
$LOC_tb.text = "$LOC"
$objForm.Controls.Add($LOC_tb)

$DNS1_tb = New-Object System.Windows.Forms.TextBox
$DNS1_tb.Location = New-Object System.Drawing.Point(55, 80)
$DNS1_tb.Size = New-Object System.Drawing.Size(200, 20)
$DNS1_tb.multiline = $false
$DNS1_tb.Enabled = $false
$DNS1_tb.text = "$env:computername"
$objForm.Controls.Add($DNS1_tb)

$DNS2_tb = New-Object System.Windows.Forms.TextBox
$DNS2_tb.Location = New-Object System.Drawing.Point(55, 100)
$DNS2_tb.Size = New-Object System.Drawing.Size(200, 20)
$DNS2_tb.multiline = $false
$DNS2_tb.Enabled = $false
$DNS2_tb.text = "$env:computername.creeknation.net"
$objForm.Controls.Add($DNS2_tb)

$DNS3_tb = New-Object System.Windows.Forms.TextBox
$DNS3_tb.Location = New-Object System.Drawing.Point(55, 120)
$DNS3_tb.Size = New-Object System.Drawing.Size(200, 20)
$DNS3_tb.multiline = $false
$DNS3_tb.Enabled = $true
$objForm.Controls.Add($DNS3_tb)

$DNS4_tb = New-Object System.Windows.Forms.TextBox
$DNS4_tb.Location = New-Object System.Drawing.Point(55, 140)
$DNS4_tb.Size = New-Object System.Drawing.Size(200, 20)
$DNS4_tb.multiline = $false
$DNS4_tb.Enabled = $true
$objForm.Controls.Add($DNS4_tb)

#labels
$CN_lb = New-Object System.Windows.Forms.label
$CN_lb.Location = New-Object System.Drawing.Size(25, 23)
$CN_lb.Size = New-Object System.Drawing.Size(100, 15)
$CN_lb.BackColor = "Transparent"
$CN_lb.ForeColor = "black"
$CN_lb.Text = "CN:"
$objForm.Controls.Add($CN_lb)

$FN_lb = New-Object System.Windows.Forms.label
$FN_lb.Location = New-Object System.Drawing.Size(1, 43)
$FN_lb.Size = New-Object System.Drawing.Size(100, 15)
$FN_lb.BackColor = "Transparent"
$FN_lb.ForeColor = "black"
$FN_lb.Text = "Friendly:"
$objForm.Controls.Add($FN_lb)

$LOC_lb = New-Object System.Windows.Forms.label
$LOC_lb.Location = New-Object System.Drawing.Size(1, 63)
$LOC_lb.Size = New-Object System.Drawing.Size(100, 15)
$LOC_lb.BackColor = "Transparent"
$LOC_lb.ForeColor = "black"
$LOC_lb.Text = "Locality:"
$objForm.Controls.Add($LOC_lb)

$DNS1_lb = New-Object System.Windows.Forms.label
$DNS1_lb.Location = New-Object System.Drawing.Size(8, 83)
$DNS1_lb.Size = New-Object System.Drawing.Size(100, 15)
$DNS1_lb.BackColor = "Transparent"
$DNS1_lb.ForeColor = "black"
$DNS1_lb.Text = "DNS 1:"
$objForm.Controls.Add($DNS1_lb)

$DNS2_lb = New-Object System.Windows.Forms.label
$DNS2_lb.Location = New-Object System.Drawing.Size(8, 103)
$DNS2_lb.Size = New-Object System.Drawing.Size(100, 15)
$DNS2_lb.BackColor = "Transparent"
$DNS2_lb.ForeColor = "black"
$DNS2_lb.Text = "DNS 2:"
$objForm.Controls.Add($DNS2_lb)

$DNS3_lb = New-Object System.Windows.Forms.label
$DNS3_lb.Location = New-Object System.Drawing.Size(8, 123)
$DNS3_lb.Size = New-Object System.Drawing.Size(100, 15)
$DNS3_lb.BackColor = "Transparent"
$DNS3_lb.ForeColor = "black"
$DNS3_lb.Text = "DNS 3:"
$objForm.Controls.Add($DNS3_lb)

$DNS4_lb = New-Object System.Windows.Forms.label
$DNS4_lb.Location = New-Object System.Drawing.Size(8, 143)
$DNS4_lb.Size = New-Object System.Drawing.Size(100, 15)
$DNS4_lb.BackColor = "Transparent"
$DNS4_lb.ForeColor = "black"
$DNS4_lb.Text = "DNS 4:"
$objForm.Controls.Add($DNS4_lb)


#request button
$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Size(280, 40)
$Button.Size = New-Object System.Drawing.Size(75, 75)
$Button.Text = "Request"
$objForm.Controls.Add($Button)


#functions

Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

function Show-Console {
    $consolePtr = [Console.Window]::GetConsoleWindow()
    [Console.Window]::ShowWindow($consolePtr, 4)
}

function Hide-Console {
    $consolePtr = [Console.Window]::GetConsoleWindow()
    [Console.Window]::ShowWindow($consolePtr, 0)
}

function RequestCert {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]$CN,
        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [string[]]$SAN,
        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [string]$CAName = "CNTV-01RSCA04.creeknation.net\creeknation-CNTV-01RSCA04-CA",
        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [string]$locality,
        [Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [string]$friendlyname
    )
    BEGIN {
        #internal function to do some cleanup
        function Remove-ReqTempfiles() {
            param(
                [String[]]$tempfiles
            )
            Write-Output "Cleanup temp files..."
            Remove-Item -Path $tempfiles -Force -ErrorAction SilentlyContinue
        }
    
        function Remove-ReqFromStore {
            param(
                [String]$CN
            )
            Write-Output "Remove pending certificate request form cert store..."
    
            #delete pending request (if a request exists for the CN)
            $certstore = new-object system.security.cryptography.x509certificates.x509Store('REQUEST', 'LocalMachine')
            $certstore.Open('ReadWrite')
            foreach ($certreq in $($certstore.Certificates)) {
                if ($certreq.Subject -eq "CN=$CN") {
                    $certstore.Remove($certreq)
                }
            }
            $certstore.close()
        }
    }
    
    PROCESS {
        Write-Output "Generating request inf file"
        $file = @"
    [NewRequest]
    Subject = "CN=$CN,OU=IT,O=MNGE,L=$locality,S=Oklahoma,C=US"
    MachineKeySet = TRUE
    FriendlyName = "$friendlyname"
    KeyLength = 4096
    KeySpec=1
    Exportable = TRUE
    RequestType = PKCS10
    ProviderName = "Microsoft Enhanced Cryptographic Provider v1.0"
    [RequestAttributes]
    CertificateTemplate = "WebServer4096(AppleCompatible)"
"@
        if (($SAN).count -eq 1) {
            $SAN = @($SAN -split ',')
        }
        $file += @'
    
    [Extensions]
    ; If your client operating system is Windows Server 2008, Windows Server 2008 R2, Windows Vista, or Windows 7
    ; SANs can be included in the Extensions section by using the following text format. Note 2.5.29.17 is the OID for a SAN extension.
    
    2.5.29.17 = "{text}"
    
'@
    
        foreach ($an in $SAN) {
            $file += "_continue_ = `"$($an)&`"`n"
        }
    
        try {
            #create temp files
            $inf = [System.IO.Path]::GetTempFileName()
            $req = [System.IO.Path]::GetTempFileName()
            $cer = Join-Path -Path $env:TEMP -ChildPath "$CN.cer"
    
            Remove-ReqTempfiles -tempfiles $inf, $req, $cer
            #create new request inf file
            Set-Content -Path $inf -Value $file -Force
    
            #show inf file if -verbose is used
            Get-Content -Path $inf | Write-Output
    
            Write-Output "Generating Request."
            Invoke-Expression -Command "certreq -new `"$inf`" `"$req`"" | out-null
            if (!($LastExitCode -eq 0)) {
                throw "certreq -new command failed"
            }
    
            write-Output "Sending Request to CA"
            Write-Output "CAName = $CAName"
            $CAName = " -config `"$CAName`""
            Invoke-Expression -Command "certreq -submit$CAName `"$req`" `"$cer`"" | out-null
    
            if (!($LastExitCode -eq 0)) {
                throw "certreq -submit command failed"
            }

            Write-Output "request was successful. Result was saved to `"$cer`""
            write-Output "retrieve and install the certificate"
            Invoke-Expression -Command "certreq -accept `"$cer`"" | out-null
            if (!($LastExitCode -eq 0)) {
                throw "certreq -accept command failed"
            }
            if (($LastExitCode -eq 0) -and ($? -eq $true)) {
                Write-Output "Certificate request successfully finished!"
            }
            else {
                throw "Request failed with unknown error. Try with -verbose -debug parameter"
            }
        }
        catch {
            Write-Error $_
        }
        finally {
            #cleanup
            Remove-ReqTempfiles -tempfiles $inf, $req, $cer
            Remove-ReqFromStore -CN $CN
            $a = new-object -comobject wscript.shell
            $a.popup("Certificate request complete. It has been added to the root store.", 0, "Complete")
        }
    }
    END {
        Remove-ReqTempfiles -tempfiles $inf, $req, $cer
    }
}




#dooo eeeett
$Button.Add_Click( {
        $objForm.Hide()
        Show-Console
        $san = @()
        if ($dns1_tb.text) { $san += $dns1_tb.text }
        if ($dns2_tb.text) { $san += $dns2_tb.text }
        if ($dns3_tb.text) { $san += $dns3_tb.text }
        if ($dns4_tb.text) { $san += $dns4_tb.text }
        $san = "DNS=" + ($san -join ",DNS=")

        $title = "Confirm Request"
        $question = "Are you sure you want to request a cert with the following details:`n`nCN: $($CN_tb.Text)`nFriendlyName: $($FN_tb.Text)`nSAN: $san`n`n"
        $choices = '&Yes', '&No'

        $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
        if ($decision -eq 0) {
            RequestCert -CN $($CN_tb.Text) -SAN $san -Locality $LOC -friendlyname "$($FN_tb.text)"
        }
        else {
            Write-Host 'cancelled'
        }
        $objForm.Close()
    })

#show the goods
$64Bit = if ([System.IntPtr]::Size -eq 4) { "" } else { "True" }
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$checkAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($64Bit) {
    if ($checkAdmin) {
        Hide-Console
        $objForm.ShowDialog()
    }
    else {
        $a = new-object -comobject wscript.shell
        $a.popup("Installer not running as Admin. Exiting.", 0, "Error")
        exit
    }
}
else {
    $a = new-object -comobject wscript.shell
    $a.popup("32Bit OS Detected. Exiting.", 0, "Error")
    exit
}
