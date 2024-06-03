if(-not (Get-Module SQLserver -ListAvailable)){
    Install-Module SQLserver -Scope CurrentUser -Force
}
else {
    $oldverbose = $VerbosePreference
    $VerbosePreference = "continue"
    Write-Verbose "CMDlet is already installed."
}
$VerbosePreference = $oldverbose


#This is the opposite verions but does the same thing
if (get-module CMDLETNAMEXXX -listavailable) {
    Write-Output "CMDlet is already installed."
}
else {
    Write-Output "Installing CMDlet $custommod."
    Install-Module $cut -Scope CurrentUser -Force
}



