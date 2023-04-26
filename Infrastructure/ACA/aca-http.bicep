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
          resources: {
            cpu: 2
            memory: '4.0Gi'
          }
        }
      ]    
      scale: {
        minReplicas: 0
        maxReplicas: 25
        rules: [
          {
            name: 'http-rule'
            http: {
              metadata: {
                concurrentRequests: '25'
              }
            }
          }
        ]
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
