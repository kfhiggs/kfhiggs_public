####Basic DNS checker script, 
#Plug DC's into this variable
$DCs = '172.18.1.206', '10.110.20.1', '10.227.20.3', '172.18.1.208', '172.18.1.207', '10.225.20.1', '10.220.20.3', '10.222.20.1', '10.226.20.2', '10.223.20.3', '10.221.20.2', '10.220.20.3'
#Test this machine against Domain DNS
$computerName = "CNtV-01NCAP07";
$DCs | %{$dc=$_; Get-DnsServerResourceRecord -Name $computerName -ZoneName creeknation.net -ComputerName $dc } | Select-Object Hostname,Timestamp,TimeToLive,@{N='DNSServer';E={$dc}} -ExpandProperty RecordData |ft -AutoSize ; #"DC=$computername,DC=creeknation.net,cn=MicrosoftDNS,DC=DomainDnsZones,DC=creeknation,DC=net" | get-adobject -Properties * | select *