try {
  Invoke-WebRequest -Uri  "http://localhost:8080/PSDSCPullServer.svc/" -ErrorAction stop | Out-Null
} 
Catch {
  $InternetIsConnected = Test-NetConnection -ComputerName '8.8.8.8' -InformationLevel Quiet
  if ($InternetIsConnected) {
    Install-Module xPsDesiredStateConfiguration -Force -AllowClobber
    Install-WindowsFeature DSC-Service -IncludeAllSubFeature -IncludeManagementTools 
    Enable-PSRemoting -Force -SkipNetworkProfileCheck 
    
    Configuration DSCPullServerConfig {
      param (
        [string[]]$ComputerName = 'localhost'
      )
      Import-DscResource -ModuleName xPsDesiredStateConfiguration
      Import-DscResource -ModuleName PSDesiredStateConfiguration

      node $ComputerName {
        WindowsFeature DSCServiceFeature {
          Ensure = "Present"
          Name = "DSC-Service"
        } #End WindowsFeature DSCServiceFeature

        xDscWebService PSDSCPullServer {
          Ensure = "Present"
          EndpointName = "PSDSCPullServer"
          Port = 8080
          PhysicalPath = "$env:systemdrive\inetpub\wwwroot\PSDSCPullServer"
          CertificateThumbPrint = "AllowUnencryptedTraffic"
          ModulePath = "$env:programfiles\windowspowershell\DSCService\Modules"
          ConfigurationPath = "$env:programfiles\windowspowershell\DSCService\Configuration"
          State = "Started"
          DependsOn = "[WindowsFeature]DSCServiceFeature"
          UseSecurityBestPractices = $false
        } # End xDscWebService PSDSCPullServer

        xDscWebService PSDSCReportServer {
          Ensure = "Present"
          EndpointName = "PSDSCReportServer"
          Port = 9080
          PhysicalPath = "$env:systemdrive\inetpub\wwwroot\PSDSCReportServer"
          State = "Started"
          DependsOn = ("[WindowsFeature]DSCServiceFeature","[xDscWebService]PSDSCPullServer")
          CertificateThumbPrint = "AllowUnencryptedTraffic"
          UseSecurityBestPractices = $false
        }  # End xDscWebService PSDSCReportServer
      } # End node $ComputerName
    } #End Configuration DSCPullServerConfig
    DSCPullServerConfig
    Start-DscConfiguration -Path .\DSCPullServerConfig -Force -Wait -Verbose
    
    try {[xml]$PullServerXML = Invoke-WebRequest -Uri  "http://localhost:8080/PSDSCPullServer.svc/" -ErrorAction stop} 
    Catch {Write-Warning "Pull Server is not working"}
  } #End if
} #End Catch
