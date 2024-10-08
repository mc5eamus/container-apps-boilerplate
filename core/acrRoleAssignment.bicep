param name string
param acrName string 
param principalId string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing  = {
  name: acrName
}

var acrPullRole = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
var acrPullRoleAssignment = guid(containerRegistry.id, acrPullRole, name)

resource acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: acrPullRoleAssignment
  scope: containerRegistry
  properties: {
    principalId: principalId
    roleDefinitionId: acrPullRole
    principalType: 'ServicePrincipal'
  }
}
