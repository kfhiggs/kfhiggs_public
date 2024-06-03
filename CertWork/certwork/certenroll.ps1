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
    
            Remove-ReqTempfiles -tempfiles $inf, $req, $cer, $rsp
            #create new request inf file
            Set-Content -Path $inf -Value $file
    
            #show inf file if -verbose is used
            Get-Content -Path $inf | Write-Output
    
            Write-Output "Generating Request."
            Invoke-Expression -Command "certreq -new `"$inf`" `"$req`""
            if (!($LastExitCode -eq 0)) {
                throw "certreq -new command failed"
            }
    
            write-Output "Sending Request to CA"
            Write-Output "CAName = $CAName"
            $CAName = " -config `"$CAName`""
            Invoke-Expression -Command "certreq -submit$CAName `"$req`" `"$cer`""
    
            if (!($LastExitCode -eq 0)) {
                throw "certreq -submit command failed"
            }

            Write-Output "request was successful. Result was saved to `"$cer`""
            write-Output "retrieve and install the certificate"
            Invoke-Expression -Command "certreq -accept `"$cer`""
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
            #show error message (non terminating error so that the rest of the pipeline input get processed)
            Write-Error $_
        }
        finally {
            #cleanup
            Remove-ReqTempfiles -tempfiles $inf, $req, $cer, $rsp
            Remove-ReqFromStore -CN $CN
        }
    }
    END {
        Remove-ReqTempfiles -tempfiles $inf, $req, $cer, $rsp
    }
}

Import-Module -Name WebAdministration
$cert = Get-ChildItem -path cert:\LocalMachine\My | Where-Object Thumbprint -eq (Get-ChildItem -Path IIS:SSLBindings).Thumbprint | select-object Subject, DnsNameList, FriendlyName
$SAN = "DNS=" + (($cert.dnsnamelist) -join ",DNS=")
$LOC = switch (($env:computername).substring(2, 1)) {
    t { "Tulsa" }
    m { "Muskogee" }
    o { "Okmulgee" }
    default { "Tulsa" }
}
RequestCert -CN $env:computername -SAN $SAN -Locality $LOC
$site = Get-ChildItem -Path "IIS:\Sites" | where-object { ( $_.Name -eq "Default Web Site" ) }
$binding = $site.Bindings.Collection | where-object { $_.protocol -eq 'https' }
$binding.AddSslCertificate("$global:thumbprint", "my")