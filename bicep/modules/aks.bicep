param name string
param location string
param dnsPrefix string
param kubernetesVersion string = '1.29.7'
param laWorkspaceId string
param vnetSubnetIdSystem string
param vnetSubnetIdUser string
param nodeSizeSystem string = 'Standard_DS2_v2'
param nodeSizeUser string   = 'Standard_DS3_v2'
param userNodeCount int = 1
param enableWorkloadIdentity bool = true

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: name
  location: location
  identity: { type: 'SystemAssigned' }
  properties: {
    dnsPrefix: dnsPrefix
    kubernetesVersion: kubernetesVersion
    oidcIssuerProfile: enableWorkloadIdentity ? { enabled: true } : null

    addonProfiles: {
      omsagent: {
        enabled: true
        config: { logAnalyticsWorkspaceResourceID: laWorkspaceId }
      }
    }

    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
      serviceCidr: '10.20.0.0/16'
      dnsServiceIP: '10.20.0.10'
      dockerBridgeCidr: '172.17.0.1/16'
      podCidr: '10.21.0.0/16'
    }

    agentPoolProfiles: [
      {
        name: 'system'
        mode: 'System'
        count: 1
        vmSize: nodeSizeSystem
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: vnetSubnetIdSystem
        osType: 'Linux'
        upgradeSettings: { maxSurge: '33%' }
        orchestratorVersion: kubernetesVersion
        enableNodePublicIP: false
      }
      {
        name: 'user'
        mode: 'User'
        count: userNodeCount
        vmSize: nodeSizeUser
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: vnetSubnetIdUser
        osType: 'Linux'
        orchestratorVersion: kubernetesVersion
        nodeTaints: []
        nodeLabels: {}
      }
    ]
  }
}

output kubeName string = aks.name
output kubeFqdn string = aks.properties.fqdn
