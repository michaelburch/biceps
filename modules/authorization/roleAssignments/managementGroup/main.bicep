targetScope = 'managementGroup'

@sys.description('Required. You can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleDefinitionIdOrName string

@sys.description('Required. The Principal or Object ID of the Security Principal (User, Group, Service Principal, Managed Identity).')
param principalId string

@sys.description('Optional. Group ID of the Management Group to assign the RBAC role to. If not provided, will use the current scope for deployment.')
param managementGroupId string = managementGroup().name

@sys.description('Optional. The description of the role assignment.')
param description string = ''

@sys.description('Optional. ID of the delegated managed identity resource.')
param delegatedManagedIdentityResourceId string = ''

@sys.description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to.')
param condition string = ''

@sys.description('Optional. Version of the condition. Currently accepted value is "2.0".')
@allowed([
  '2.0'
])
param conditionVersion string = '2.0'

@sys.description('Optional. The principal type of the assigned principal ID.')
@allowed([
  'ServicePrincipal'
  'Group'
  'User'
  'ForeignGroup'
  'Device'
  ''
])
param principalType string = ''

@sys.description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

@sys.description('Optional. Location deployment metadata.')
param location string = deployment().location

var builtInRoleNames = json(loadTextContent('../../../../azure-roles.json'))

var roleDefinitionId_var = (contains(builtInRoleNames, roleDefinitionIdOrName) ? builtInRoleNames[roleDefinitionIdOrName] : roleDefinitionIdOrName)

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  location: location
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(managementGroupId, roleDefinitionId_var, principalId)
  properties: {
    roleDefinitionId: roleDefinitionId_var
    principalId: principalId
    description: !empty(description) ? description : null
    principalType: !empty(principalType) ? any(principalType) : null
    delegatedManagedIdentityResourceId: !empty(delegatedManagedIdentityResourceId) ? delegatedManagedIdentityResourceId : null
    conditionVersion: !empty(conditionVersion) && !empty(condition) ? conditionVersion : null
    condition: !empty(condition) ? condition : null
  }
}

@sys.description('The GUID of the Role Assignment.')
output name string = roleAssignment.name

@sys.description('The resource ID of the Role Assignment.')
output resourceId string = extensionResourceId(tenantResourceId('Microsoft.Management/managementGroups', managementGroupId), 'Microsoft.Authorization/roleAssignments', roleAssignment.name)

@sys.description('The scope this Role Assignment applies to.')
output scope string = tenantResourceId('Microsoft.Management/managementGroups', managementGroupId)
