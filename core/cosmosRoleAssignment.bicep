@description('CosmosDB Account to apply the role assignment to')
param databaseAccountName string
@description('Principal id to assign the role to')
param principalId string

var roleDefinition = '00000000-0000-0000-0000-000000000002'
var roleAssignmentId = guid(databaseAccount.id, roleDefinition, principalId)

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: databaseAccountName
}

resource sqlContributorRoleDef 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2023-04-15' existing = {
  parent: databaseAccount
  name: roleDefinition
}

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-04-15' = {
  name: roleAssignmentId
  parent: databaseAccount
  properties:{
    principalId: principalId
    roleDefinitionId: sqlContributorRoleDef.id
    scope: databaseAccount.id
  }
}
