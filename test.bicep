targetScope = 'subscription'
var spokeName = 'rocketchat'
var targetResourceGroup = spokeName
param targetLocation string = deployment().location

var tags = {
  createdWith: 'bicep'
  project: spokeName
}

module rg 'br:biceps.azurecr.io/modules/resourcegroups:v0.6.0' = {
  name: targetResourceGroup
  params: {
    location: targetLocation
    name: targetResourceGroup
    tags: tags
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Contributor'
        principalId: '43987329-6eb9-4ce9-b34e-d18c12b72e4f'
      }
    ]
  }
}
