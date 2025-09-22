param name string
param location string
param addressPrefix string = '10.10.0.0/16'
param subnets array = [
  { name: 'aks-system'; prefix: '10.10.0.0/24' }
  { name: 'aks-user';   prefix: '10.10.1.0/24' }
]

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: name
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ addressPrefix ] }
    subnets: [for s in subnets: {
      name: s.name
      properties: { addressPrefix: s.prefix }
    }]
  }
}

output subnetIds object = {
  for s in subnets: s.name => vnet::subnets[s.name].id
}
