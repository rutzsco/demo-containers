param location string
param name string
param servicename string
param containerAppEnvironmentId string

// Container Image ref
param containerImage string

// Networking
param useExternalIngress bool = false
param containerPort int

param envVars array = []
param secrets array = []

param acrName string
param acrUsername string

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: name
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironmentId
    configuration: {
      secrets: secrets
      registries: [
        {
          server: '${acrName}.azurecr.io'
          username: acrUsername
          passwordSecretRef: 'acrpassword'
        }
      ]
      ingress: {
        external: useExternalIngress
        targetPort: containerPort
      }
      dapr: {
        enabled: true
        appPort: containerPort
        appId: servicename
        appProtocol: 'http'
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: name
          env: envVars
        }
      ]    
      scale: {
        minReplicas: 1
        maxReplicas: 10
        rules: [ {
            name: 'http-scaling-rule'
            http: {
              metadata: {
                type: 'concurrentRequests'
                value: '5'
              }
            }
          } ]
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
