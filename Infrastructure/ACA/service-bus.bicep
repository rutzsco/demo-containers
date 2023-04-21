// parameters
@minLength(3)
@maxLength(32)
param serviceBusName string


@allowed([
  'Basic'  
  'Standard'
  'Premium'
])
param sku string = 'Standard'
param location string = resourceGroup().location


resource sb 'Microsoft.ServiceBus/namespaces@2021-01-01-preview' = {
  name: serviceBusName
  location: location
  sku: {
    name: sku
  }
  properties: {
  }
}

output name string = sb.name
output id string = sb.id
output connectionString string = sb.properties.serviceBusEndpoint
