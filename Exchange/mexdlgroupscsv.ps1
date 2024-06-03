Set-ExecutionPolicy RemoteSigned
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://<ServerFQDN>/PowerShell/ -Authentication Kerberos -Credential $UserCredential

Get-DistributionGroup -ResultSize Unlimited | Export-Csv C:\temp


#search mailbox between times
Search-Mailbox -SearchQuery {from:emailadressname@domain.com AND Received:"05/24/2021 10:00..08/24/2021 13:00"}

#maybe try this one?
get-mailboxfolderstatistics




| Export-Csv C:\temp