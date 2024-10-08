param name string 
param location string = resourceGroup().location

resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: name
  location: location
}

output name string = uai.name
output principalId string = uai.properties.principalId
output clientId string = uai.properties.clientId
