param appName string
param location string = resourceGroup().location
param alwaysOn bool = true
param sku string = 'Basic'
param skuCode string = 'B1'
param workerSize string = '0'
param workerSizeId string = '0'
param numberOfWorkers string = '1'
param linuxFxVersion string
param dockerRegistryUrl string = 'https://rutzscocr.azurecr.io'
param dockerRegistryUsername string = 'rutzscocr'

@secure()
param dockerRegistryPassword string
param applicationVersion string = 'unknown'

var hostingPlanName_var = appName

resource appName_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: appName
  location: location
  tags: null
  properties: {
    name: appName
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: dockerRegistryUrl
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerRegistryUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: dockerRegistryPassword
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'APPLICATION_VERSION'
          value: applicationVersion
        }
      ]
      linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
    }
    serverFarmId: hostingPlanName.id
    clientAffinityEnabled: false
  }
}

resource hostingPlanName 'Microsoft.Web/serverfarms@2015-08-01' = {
  name: hostingPlanName_var
  location: location
  kind: 'linux'
  tags: null
  properties: {
    name: hostingPlanName_var
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    reserved: true
  }
  sku: {
    tier: sku
    name: skuCode
  }
  dependsOn: []
}
