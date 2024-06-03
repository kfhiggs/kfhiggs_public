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
        [string]$locality
    )
    BEGIN {
        #internal function to do some cleanup
        $date = get-date -format "yyyy-MM-dd"
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
    FriendlyName = "$CN $date"
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
                $global:thumbprint = (New-Object System.Security.Cryptography.X509Certificates.X509Certificate2((Get-Item $cer).FullName, "")).Thumbprint
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
        }
    }
    END {
        Remove-ReqTempfiles -tempfiles $inf, $req, $cer
    }
}

Import-Module -Name WebAdministration
$cert = Get-ChildItem -path cert:\LocalMachine\My | Where-Object Thumbprint -eq (Get-ChildItem -Path IIS:SSLBindings).Thumbprint | select-object Subject, DnsNameList, FriendlyName
if ($cert) {
    $SAN = "DNS=" + (($cert.dnsnamelist) -join ",DNS=")
    $LOC = switch (($env:computername).substring(2, 1)) {
        t { "Tulsa" }
        m { "Muskogee" }
        o { "Okmulgee" }
        default { "Tulsa" }
    }
    $date = (Get-ChildItem -path cert:\LocalMachine\My | Where-Object Thumbprint -eq (Get-ChildItem -Path IIS:SSLBindings).Thumbprint | select-Object -expandproperty NotAfter) | get-date -format "MM/dd/yyyy"



    $title = "Confirm Renew"
    $question = "The certificate expires on $date. Are you sure you want to proceed?"
    $choices = '&Yes', '&No'

    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 0) {
        RequestCert -CN $env:computername -SAN $SAN -Locality $LOC
        $site = Get-ChildItem -Path "IIS:\Sites" | where-object { ( $_.Name -eq "Default Web Site" ) }
        $binding = $site.Bindings.Collection | where-object { $_.protocol -eq 'https' }
        $binding.AddSslCertificate("$global:thumbprint", "my")
    }
    else {
        Write-Host 'cancelled'
    }
}