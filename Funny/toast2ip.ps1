# Import the necessary modules
Add-Type -AssemblyName System.Windows.Forms

# Set the remote computer's IP address
$remoteHOST = "cctl-itdsys08"

# Create a new ToastNotifier object
$toaster = New-Object System.Windows.Forms.NotifyIcon

# Set the toast message and title
$message = "Where's my car!"
$title = "Dudeeeeeeeeee"

# Send the toast notification to the remote computer
$toaster.ShowBalloonTip(5, $title, $message, [System.Windows.Forms.ToolTipIcon]::None)