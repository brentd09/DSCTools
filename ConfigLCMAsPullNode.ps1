# This needs to be run on the pull clients
[DSCLocalConfigurationManager()]
configuration PullClientConfig {
  Node localhost {
    Settings {
      RefreshMode = 'Pull'
      ConfigurationID = '1d545e3b-60c3-47a0-bf65-5afc05182fd0'
      ConfigurationMode = 'ApplyandAutoCorrect'
      RefreshFrequencyMins = 30 
      RebootNodeIfNeeded = $true
    }
    ConfigurationRepositoryWeb LON-DC1 {
      ServerURL = 'http://LON-DC1:8080/PSDSCPullServer.svc'
    }      
  }
}
PullClientConfig
Set-DscLocalConfigurationManager localhost -path .\PullClientConfig 
