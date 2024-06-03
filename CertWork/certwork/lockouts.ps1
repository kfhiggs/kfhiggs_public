$lockouts = import-csv "\\creeknation.net\ss_shares\Information_Technology\Infrastructure\Varonis\SchedSearches\48hr_Lockout\48hr_Lockout.Csv"
$formatted = $lockouts | select-object @{n = 'Date'; e = { Get-Date ($_.'Event Time') -Format "MM/dd/yyyy" } }, @{n = 'SamAccountName'; e = { ($_.'SAM Account Name (Event By)').replace("creeknation.net\", "") } }
$userstoday = $formatted  | where-object { $_.'Date' -eq (Get-Date).AddDays(-1).ToString("MM/dd/yyyy") } | sort-object -unique -Property SamAccountName
$usersyesterday = $formatted  | where-object { $_.'Date' -eq (Get-Date).AddDays(-2).ToString("MM/dd/yyyy") } | sort-object -unique -Property SamAccountName

$repeats = compare-object $userstoday $usersyesterday -Property SamAccountName -IncludeEqual | where-object SideIndicator -eq "==" | select-object -expandproperty SamAccountName
$finallist = @()
$sendmail = ""
if ($repeats) {
    $sendmail = "True"
    foreach ($user in $repeats) {
        $finallist += $lockouts | where-object 'SAM Account Name (Event By)' -eq "creeknation.net\$user"
    }
    $header = @"
<style>
    .wrapper {
        display: grid;
        grid-template-columns: repeat(4);
        grid-gap: 10px;
        grid-auto-rows: minmax(100px, auto);
        margin: auto;
    }

    h1 {
        font-family: Arvo, Helvetica, sans-serif;
        color: #395870;
        font-size: 36px;
        text-align: center;
    }
    h2 {
        font-family: Arvo, Helvetica, sans-serif;
        color: #395870;
        font-size: 26px;
        text-align: center;
    }
   table {
		font-size: 18px;
		border: 0px; 
        font-family: Arvo, Helvetica, sans-serif;
        width: 100%;
	}
    td {
		padding: 18px;
		margin: 0px;
        border: 0;
        text-align: center;
    }
    td.title {
        font-family: Arvo, Helvetica, sans-serif;
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 14px;
        text-transform: uppercase;
        padding: 5px 10px;
        vertical-align: middle;
    }
    table.clist td:nth-child(1) {
        width: 200px;
      }
    table.clist td:nth-child(2) {
        color: #ff0000;
      }
      
    table.clist td:nth-child(3) {
        color: #008000;
      }
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 14px;
        text-transform: uppercase;
        padding: 5px 10px;
        vertical-align: middle;
	}
    td {
        padding: 10px 10px;
    }
    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }
    .CreationDate {
        font-size: 11px;
    }
</style>
"@
    $Info = $finallist | where-object { ($_.'Event Time' -match (Get-Date).AddDays(-1).ToString("M/d/yyyy")) -or ($_.'Event Time' -match (Get-Date).AddDays(-2).ToString("M/d/yyyy")) } | sort-object -unique -property { $_."Event Time" -as [datetime] } | ConvertTo-Html -Title "48 Hr Repeat Lockouts"
    $Report = ConvertTo-HTML -Body "<div class='wrapper' style='width:60%;'><div class='title' style='grid-column: 1;grid-row: 1;'><h1>48 Hr Repeat Lockouts</h1></div><div class='summary' style='grid-column: 1;grid-row: 2;'><h2>Summary</h2>$Info</div>" -Head $header -Title "48 Hr Repeat Lockouts" -PostContent "<div class='footer' style='grid-column: 1;grid-row: 3;'><p class='CreationDate'>Creation Date: $(Get-Date)</p></div></div>"
    #$Report | Out-File "\\creeknation.net\ss_shares\Information_Technology\Infrastructure\Varonis\48HrLockoutLog\48HrLockoutLog.html"

}
else {
    $sendmail = "False"
}