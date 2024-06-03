#place .csv in c:\temp
$CsvOutputPath = "c:\temp\pingtestResult.csv"
$CsvInput = Get-Content "c:\temp\ip4.csv"

foreach ($i in $CsvInput) {
    $Result = [PSCustomObject]@{
        DNSName    = $i.Trim()
        HostName   = ""
        DNSIPv4    = ""
        Up         = ""
        TestedIPv4 = ""
    }
    
    Try {
        $Entry = [System.Net.Dns]::GetHostEntry($i.Trim())
        $Result.HostName = $Entry.HostName
        $Entry.AddressList |
        Where-Object { $_.AddressFamily -eq 'InterNetwork' } |
        ForEach-Object {
            $Result.DNSIPv4 = $_.IPAddressToString
            #$x = Test-NetConnection -ComputerName $Result.DNSName -InformationLevel Quiet
            [array]$x = Test-Connection -Delay 15 -ComputerName $Result.DNSName -Count 1 -ErrorAction SilentlyContinue
            if ($x) {
                $Result.Up = "Yes"
                $Result.TestedIPv4 = $x[0].IPV4Address
            }
            else {
                $Result.Up = "No"
                $Result.TestedIPv4 = "N/A"
            }
        }
    }
    Catch {
        $Result.HostName = "Host Unknown"
        $Result.Up = "Unknown"
        $Result.TestedIPv4 = "N/A"
    }
    # outputs to the screen
    $Result
    Export-Csv -InputObject $Result -Path $CsvOutputPath -NoTypeInformation -Append
} 