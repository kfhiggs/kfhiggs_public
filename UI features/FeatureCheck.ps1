if(get-module -list activedirectory){'found'
}else{Add-Type -AssemblyName PresentationCore,PresentationFramework
    $msgBody = "RSAT is not installed on this machine, please install RSAT and retry"
    [System.Windows.MessageBox]::Show($msgBody)}