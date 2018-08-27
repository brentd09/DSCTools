try {
  Invoke-WebRequest -Uri  "http://localhost:8080/PSDSCPullServer.svc/" -ErrorAction stop | Out-Null
} 
Catch {
  $InternetIsConnected = Test-NetConnection -ComputerName '8.8.8.8' -InformationLevel Quiet
  if ($InternetIsConnected) {
    Install-Module xPsDesiredStateConfiguration -Force -AllowClobber 
    Install-WindowsFeature DSC-Service -IncludeAllSubFeature -IncludeManagementTools 
    Enable-PSRemoting -Force -SkipNetworkProfileCheck 
    .\Create-PullServer.ps1
  } #End if
} #End Catch