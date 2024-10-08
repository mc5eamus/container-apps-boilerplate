targetScope='subscription'

@minLength(3)
@description('The name of the project as in project-environment-salt pattern used for naming resources')
param project string
@minLength(3)
@description('The environment as in project-environment-salt pattern used for naming resources')
param environment string
@minLength(1)
@description('A unique string to add to the resource names to ensure uniqueness')
param salt string
@description('The location where the resources will be deployed')
param location string = 'switzerlandnorth'

@description('Does the environment need to be integrated with an existing vNet')
param customVnet bool = false
@description('If customVnet is true, provide the name of the vNet')
param customVnetName string
@description('If customVnet is true, provide the name of the subnet. Make sure the subnet is delegated to Microsoft.App/environments')
param customSubnetName string
@description('If customVnet is true, provide the resource group of the vNet')
param customVnetResourceGroup string = ''


param acrName string = ''
param acrResourceGroup string = ''
param imageNameApi string = ''
param imageNameBackend string = ''
param imageVersion string = 'latest'

var longName = '${project}-${environment}-${salt}'

resource deploymentResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: longName
  location: location
}

module monitoring 'core/monitor.bicep' = {
  name: 'monitoring'
  scope: deploymentResourceGroup
  params: {
    name: 'mon-${longName}'
    location: location
  }
}

module containerAppsEnvironment 'core/appenvironment.bicep' = {
  name: 'containerAppsEnvironment'
  scope: deploymentResourceGroup
  params: {
    name: 'aca-${longName}'
    location: location
    logAnalyticsName: monitoring.outputs.logAnalyticsName
    connectToVnet: customVnet
    //internal: true
    vnetName: customVnetName
    subnetName: customSubnetName
    vnetResourceGroup: customVnetResourceGroup
  }
}

module cosmos 'core/cosmos.bicep' = {
  name: 'cosmos'
  scope: deploymentResourceGroup
  params: {
    accountName: 'cosmos-${longName}'
    databaseName: 'repo'
    containerName: 'items'
  }
}

output debug string = 'acrName: ${acrName}, acrResourceGroup: ${acrResourceGroup}, imageNameApi: ${imageNameApi}, imageNameBackend: ${imageNameBackend}, imageVersion: ${imageVersion}'

