import-module posh-ssh

$creds = Get-Credential
$device = "10.120.44.7"
$cmd = "journalctl | grep -Ei 'dhcp'"
$dhcp = (Invoke-SSHCommand -SSHSession (New-SSHSession -ComputerName $device -Credential $creds -AcceptKey) -Command $cmd).output

$dhcp | out-file "C:\temp\healthy.txt" 