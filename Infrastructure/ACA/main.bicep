param location string = resourceGroup().location
param envName string
param appName string
param containerImage string
param containerPort int = 80

module law 'log-analytics.bicep' = {
	name: 'log-analytics-workspace'
	params: {
      location: location
      name: 'law-${envName}'
	}
}

module containerAppEnvironment 'aca-environment.bicep' = {
  name: 'container-app-environment'
  params: {
    name: envName
    location: location
    
    lawClientId:law.outputs.clientId
    lawClientSecret: law.outputs.clientSecret
  }
}

module containerApp 'aca.bicep' = {
  name: appName
  params: {
    name: appName
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    envVars: []
    useExternalIngress: true
    containerPort: containerPort

  }
}

output fqdn string = containerApp.outputs.fqdn
