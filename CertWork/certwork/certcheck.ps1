$cert = invoke-command -computername cntv-02wtol01 -scriptblock { Import-Module -Name WebAdministration; Get-ChildItem -path cert:\LocalMachine\My | Where-Object Thumbprint -eq (Get-ChildItem -Path IIS:SSLBindings).Thumbprint | select-object Subject, DnsNameList, FriendlyName }

$dns = "DNS=" + ($cert.dnsnamelist -join ",DNS=")
$subject = $cert.Subject
$friendlyname = $cert.friendlyname