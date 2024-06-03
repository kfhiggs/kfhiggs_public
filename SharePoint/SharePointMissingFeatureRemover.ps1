

#Site Scope - Used for 00000000000000-0000-0000 WebIDs
$site = Get-SPSite -Limit All | ? { $_.Id -eq "CAB3BC8E-6AFC-47FE-A0B8-935E93C1630E" }
$siteFeature = $site.Features["XXFeatureID"]
$site.Features.Remove($siteFeature.DefinitionId, $true)


#Web Scope
$site = Get-SPSite -Limit all | where { $_.Id -eq “CAB3BC8E-6AFC-47FE-A0B8-935E93C1630E” } 
$web = $site | Get-SPWeb -Limit all | where { $_.Id -eq "XXWebID"  }
$webFeature = $web.Features["XXFeatureID"]
$web.Features.Remove($webFeature.DefinitionId, $true)





#This takes the csv created from SQL and removes the feature for Web scope items, for site scope use other script 
$path = "C:\CSVtest\siteidsSPmig.csv"
$csv = import-csv -path $path

foreach ($line in $csv) {
    Write-Output "Running script for SiteID $($line.SiteID), WebID $($line.WebID), FeatureID $($line.FeatureID)"
    $site = Get-SPSite -Limit all | where-object { $_.Id -eq “$($line.SiteID)” } 
    $web = $site | Get-SPWeb -Limit all | where-object { $_.Id -eq "$($line.WebID)" }
    $webFeature = $web.Features["$($line.FeatureID)"]
    $web.Features.Remove($webFeature.DefinitionId, $true)
} 