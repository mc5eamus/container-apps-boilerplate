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
param customVnetName string = ''	
@description('If customVnet is true, provide the name of the subnet. Make sure the subnet is delegated to Microsoft.App/environments')
param customSubnetName string = ''	
@description('If customVnet is true, provide the resource group of the vNet')
param customVnetResourceGroup string = ''

@description('The name of the Azure Container Registry')
param acrName string = ''
@description('The name of the resource group where the Azure Container Registry (ACR) is located.')
param acrResourceGroup string = ''
@description('The name of the container image for the API.')
param imageNameApi string = ''
@description('The name of the container image for the backend.')
param imageNameBackend string = ''
@description('The version of the container images.')
param imageVersion string = ''


var longName = '${project}-${environment}-${salt}'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: longName
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  scope: rg
  name: 'aca-${longName}'
}

resource appInsights 'microsoft.insights/components@2020-02-02' existing = {
  scope: rg
  name: 'mon-${longName}'
}

module uai 'core/identity.bicep' = {
  name: 'uai'
  scope: rg
  params: {
    name: 'uai-min-${longName}'
    location: location
  }
}

module whoamiApp 'app/app.bicep' = {
  name: 'whoami'
  scope: rg
  params: {
    name: 'whoami'
    location: location
    environmentId: containerAppEnv.id
    image: 'traefik/whoami'
    targetPort: 80
    daprEnabled: false
    ingressEnabled: true
    uaiName: uai.outputs.name
    environmentVariables: [
      {
        name: 'env-01'
        value: 'value-01'
      }
      {
        name: 'env-02'
        value: 'value-02'
      }
    ]
  }
}

module uaiWithExtendedAccess 'core/identity.bicep' = {
  name: 'uaiWithAcrAccess'
  scope: rg
  params: {
    name: 'uai-int-${longName}'
    location: location
  }
}

module roleAssignmentAcr 'core/acrRoleAssignment.bicep' =  {
  name: 'roleAssignment'
  scope: resourceGroup(acrResourceGroup)
  params: {
    name: 'acr-${longName}'
    acrName: acrName
    principalId: uaiWithExtendedAccess.outputs.principalId
  }
}

module roleAssignmentCosmos 'core/cosmosRoleAssignment.bicep' =  {
  name: 'roleAssignmentCosmos'
  scope: rg
  params: {
    databaseAccountName: 'cosmos-${longName}'
    principalId: uaiWithExtendedAccess.outputs.principalId
  }
}

module appBackend 'app/app.bicep' = {
  name: 'app-backend'
  scope: rg
  params: {
    name: imageNameBackend
    location: location
    environmentId: containerAppEnv.id
    image: '${acrName}.azurecr.io/${imageNameBackend}:${imageVersion}'
    registryServer: '${acrName}.azurecr.io'
    targetPort: 80
    daprEnabled: false
    ingressEnabled: true
    ingressExternal: true
    uaiName: uaiWithExtendedAccess.outputs.name
    concurrentRequestsPerInstance: 50
    maxReplicas: 25
    environmentVariables: [
      {
        name: 'AZURE_CLIENT_ID'
        value: uaiWithExtendedAccess.outputs.clientId
      }
      {
        name: 'CosmosEndpoint'
        value: 'https://cosmos-${longName}.documents.azure.com:443/'
      }
      {
        name: 'CosmosDatabase'
        value: 'repo'
      }
      {
        name: 'CosmosContainer'
        value: 'items'
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: appInsights.properties.ConnectionString
      }
      {
        name: 'OTEL_RESOURCE_ATTRIBUTES'
        value: 'service.namespace=containerapps-boilerplate,service.instance.id=backend'
      }
      {
        name: 'OTEL_SERVICE_NAME'
        value: 'containerapps-boilerplate-backend'
      }
    ]
  }
  dependsOn: [
    roleAssignmentAcr
  ]
}

module appApi 'app/app.bicep' = {
  name: 'app-api'
  scope: rg
  params: {
    name: imageNameApi
    location: location
    environmentId: containerAppEnv.id
    image: '${acrName}.azurecr.io/${imageNameApi}:${imageVersion}'
    registryServer: '${acrName}.azurecr.io'
    targetPort: 80
    daprEnabled: false
    ingressEnabled: true
    uaiName: uaiWithExtendedAccess.outputs.name
    concurrentRequestsPerInstance: 25
    maxReplicas: 25
    environmentVariables: [
      {
        name: 'AZURE_CLIENT_ID'
        value: uaiWithExtendedAccess.outputs.clientId
      }
      {
        name: 'backend'
        value: 'https://${imageNameBackend}.${containerAppEnv.properties.defaultDomain}'
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: appInsights.properties.ConnectionString
      }
      {
        name: 'OTEL_RESOURCE_ATTRIBUTES'
        value: 'service.namespace=containerapps-boilerplate,service.instance.id=api'
      }
      {
        name: 'OTEL_SERVICE_NAME'
        value: 'containerapps-boilerplate-api'
      }      
    ]
  }
  dependsOn: [
    roleAssignmentAcr
    appBackend
  ]
}


output customVnetConfig string = customVnet ? 'Vnet: ${customVnetName}, Subnet: ${customSubnetName}, RG: ${customVnetResourceGroup}' : 'no vnet integration'

