param location string
param name string
param containerAppEnvironmentId string

// Container Image ref
param containerImage string

// Networking
param useExternalIngress bool = false
param containerPort int

param envVars array = []

param acrName string
param acrUsername string
@secure()
param acrPassword string

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: name
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironmentId
    configuration: {  
      secrets: [
        {
            name: 'acrPassword'
            value: acrPassword
        }
    ]
    registries: [
        {
            server: '${acrName}.azurecr.io'
            username: acrUsername
            passwordSecretRef: 'acrPassword'
        }
    ]
      ingress: {
        external: useExternalIngress
        targetPort: containerPort
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
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
