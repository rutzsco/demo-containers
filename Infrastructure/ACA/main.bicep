param location string = resourceGroup().location
param envName string
param appName string
param containerImage string
param containerPort int = 80
@secure()
param acrPassword string
param acrUsername string
param acrName string

var stackname = '${appName}-${envName}'

// Service Bus
module sb 'service-bus.bicep' = {
  name: 'sb'
  
  params: {
    location: location
    serviceBusName: stackname
  }
}

module law 'log-analytics.bicep' = {
	name: 'log-analytics-workspace'
	params: {
      location: location
      name: stackname
	}
}

module containerAppEnvironment 'aca-environment.bicep' = {
  name: 'container-app-environment'
  params: {
    name: stackname
    location: location
    
    lawClientId:law.outputs.clientId
    lawClientSecret: law.outputs.clientSecret
    appInsightsConnectionString: law.outputs.applicationInsightsConnectionString
  }
}

var containerImageParts = split(containerImage, ':')
var envVars  = [
  {
    name: 'APPLICATION_VERSION'
    value: containerImageParts[1]
  } 
  {
    name: 'DEPLOYMENT_RING'
    value: 'Production1'
  } 
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: law.outputs.applicationInsightsConnectionString
  }]

module containerApp 'aca.bicep' = {
  name: 'container-app'
  params: {
    name: stackname
    servicename: stackname
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    envVars: envVars
    useExternalIngress: true
    containerPort: containerPort
    secrets: [
      {
        name: 'acrpassword'
        value: acrPassword
      }
    ]
    acrUsername: acrUsername
    acrName: acrName
  }
}

module containerAppHttp 'aca-http.bicep' = {
  name: 'container-app-http'
  params: {
    name: '${stackname}-http'
    servicename: '${stackname}-http'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    envVars: envVars
    useExternalIngress: true
    containerPort: containerPort
    secrets: [
      {
        name: 'acrpassword'
        value: acrPassword
      }
    ]
    acrUsername: acrUsername
    acrName: acrName
  }
}

module containerAppRev 'aca-http.bicep' = {
  name: 'container-app-rev'
  params: {
    name: '${stackname}-rev'
    servicename: '${stackname}-rev'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    envVars: envVars
    useExternalIngress: true
    containerPort: containerPort
    secrets: [
      {
        name: 'acrpassword'
        value: acrPassword
      }
    ]
    acrUsername: acrUsername
    acrName: acrName
  }
}
output fqdn string = containerApp.outputs.fqdn
