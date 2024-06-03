#Get the Farm Account
$FarmAccount = Read-Host "Enter the Farm Account in Domain\User Format:"
  
#Get the changed Password for the farm account
$Password = Read-Host "Enter the changed password for Farm Account" -AsSecureString
  
#Update the password for farm account
Set-SPManagedAccount -Identity $FarmAccount -ExistingPassword $Password -UseExistingPassword $true