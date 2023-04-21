param name string
param location string
param lawClientId string

@secure()
param lawClientSecret string
@secure()
param appInsightsConnectionString string

resource env 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: lawClientId
        sharedKey: lawClientSecret
      }
    }
    daprAIConnectionString: appInsightsConnectionString
  }
}
output id string = env.id

