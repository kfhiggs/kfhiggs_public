$ADGroupList = (Get-ADGroup -Filter * -searchbase "OU=Job Role Groups,OU=Security Groups,DC=creeknation,DC=net" -Properties *).Name
$ADGroupList | out-file "C:\temp\adgrouplist.csv"