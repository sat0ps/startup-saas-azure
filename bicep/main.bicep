targetScope = 'resourceGroup'

@description('Base name prefix, e.g., "brian-dev"')
param baseName string = 'brian-dev'
@description('Location')
param location string = resourceGroup().location

module vnet './modules/vnet.bicep' = {
  name: '${baseName}-vnet'
  params: {
    name: '${baseName}-vnet'
    location: location
  }
}

module la './modules/la.bicep' = {
  name: '${baseName}-la'
  params: {
    name: '${baseName}-la'
    location: location
  }
}

module acr './modules/acr.bicep' = {
  name: '${baseName}-acr'
  params: {
    name: replace('${baseName}acr','-','')  // ACR name must be alphanumeric
    location: location
    sku: 'Basic'
  }
}

module aks './modules/aks.bicep' = {
  name: '${baseName}-aks'
  params: {
    name: '${baseName}-aks'
    location: location
    dnsPrefix: '${baseName}-dns'
    laWorkspaceId: la.outputs.workspaceId
    vnetSubnetIdSystem: vnet.outputs.subnetIds['aks-system']
    vnetSubnetIdUser:   vnet.outputs.subnetIds['aks-user']
  }
}

output aksName string = aks.outputs.kubeName
output aksFqdn string = aks.outputs.kubeFqdn
output acrId string = acr.outputs.acrId
