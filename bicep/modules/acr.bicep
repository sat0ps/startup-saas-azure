param name string
param location string
param sku string = 'Basic'

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: { name: sku }
  properties: { adminUserEnabled: false }
}

output acrId string = acr.id
