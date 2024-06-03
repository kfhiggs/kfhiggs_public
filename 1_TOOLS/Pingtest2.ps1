$Output= @()

$names = Get-Content "c:\temp\ip4.csv"

foreach ($name in $names){

if (Test-Connection -Delay 15 -ComputerName $name -Count 1 -ErrorAction SilentlyContinue){

$Output+= "$name"

Write-Host "$Name" -ForegroundColor Green

}

else{

$Output+= "$name"

Write-Host "$Name" -ForegroundColor Red

}

}

$Output | Out-file "c:\temp\pingtestresult.csv"