targetScope = 'subscription'

@description('Required. The name of the Resource Group.')
param name string

@description('Optional. Location of the Resource Group. It uses the deployment\'s location when not provided.')
param location string = deployment().location

@allowed([
  ''
  'CanNotDelete'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = ''

@description('Optional. Dictionary of Azure Built-in Role Names and IDs')
param builtInRoleNames object = {}

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments array = []

@description('Optional. Tags of the storage account resource.')
param tags object = {}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2019-05-01' = {
  location: location
  name: name
  tags: tags
  properties: {}
}

module resourceGroup_lock 'br:biceps.azurecr.io/modules/authorization/locks/resourcegroup:v0.6.0' = if (!empty(lock)) {
  name: '${uniqueString(deployment().name, location)}-${lock}-Lock'
  params: {
    level: any(lock)
    name: '${resourceGroup.name}-${lock}-lock'
  }
  scope: resourceGroup
}

resource resourceGroup_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roleAssignment, index) in roleAssignments: {
  name: guid(last(split(roleAssignment.resourceId, '/')), roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
  properties: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    roleDefinitionId: contains(builtInRoleNames, roleAssignment.roleDefinitionIdOrName) ? builtInRoleNames[roleAssignment.roleDefinitionIdOrName] : roleAssignment.roleDefinitionIdOrName
    principalId: roleAssignment.principalId
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : null
    condition: contains(roleAssignment, 'condition') ? roleAssignment.condition : null
    conditionVersion: contains(roleAssignment, 'condition') ? '2.0' : null
    delegatedManagedIdentityResourceId: contains(roleAssignment, 'delegatedManagedIdentityResourceId') ? roleAssignment.delegatedManagedIdentityResourceId : ''
  }
}]

@description('The name of the resource group.')
output name string = resourceGroup.name

@description('The resource ID of the resource group.')
output resourceId string = resourceGroup.id

@description('The location the resource was deployed into.')
output location string = resourceGroup.location
