param name string
param location string = resourceGroup().location
param logAnalyticsName string
param connectToVnet bool = false
param internal bool = false
param vnetName string = ''
param subnetName string = ''
param vnetResourceGroup string = ''

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsName
}

// Reference existing VNet
resource vNet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = if (connectToVnet) {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)
}

// Reference existing Subnet
resource vNetSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = if (connectToVnet) {
  parent: vNet
  name: subnetName
}

resource containerAppEnvInVnet 'Microsoft.App/managedEnvironments@2024-03-01' = if(connectToVnet) {
  name: name
  location: location
  properties: {
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
    vnetConfiguration: {
      internal: internal
      infrastructureSubnetId: vNetSubnet.id
    } 
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    infrastructureResourceGroup: '${resourceGroup().name}-acainfra'
  }
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' = if(!connectToVnet) {
  name: name
  location: location
  properties: {
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    infrastructureResourceGroup: '${resourceGroup().name}-acainfra'
  }
}
