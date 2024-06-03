function wsus_off {
    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name UseWUServer 0
    Restart-Service wuauserv
  }
  
  function wsus_on {
    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name UseWUServer 1
    Restart-Service wuauserv
  }
  
  wsus_off 