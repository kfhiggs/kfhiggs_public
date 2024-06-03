function buildUsers {
    #define empty array
    $global:userList = @()
    foreach ($ein in $einList) {
        $user = Get-ADUser -Filter { Office -like $ein } -Properties EmailAddress | select-object SamAccountName, Name, GivenName, SurName, EmailAddress, UserPrincipalName
        #make sure something returns
        if ([bool]$user) {
            #make sure only 1 returns
            if (((($user | Measure-Object).count) -eq 1)) {
                #structure data for new array
                $data = New-Object psobject -Property @{
                    "EIN"            = $ein;
                    "SamAccountName" = $user.SamAccountName;
                    "FullName"       = $user.Name;
                    "FirstName"      = $user.GivenName;
                    "LastName"       = $user.SurName;
                    "Email"          = $user.EmailAddress;
                    "UPN"            = $user.UserPrincipalName;
                }
                #add line data for each user in einlist
                $global:userList += $data | Select-Object EIN, SamAccountName, FullName, FirstName, LastName, Email, UPN
            }
            else {
                errorHandler -code 3
            }
        }
        else {
            errorHandler -code 4
        }
    }
}