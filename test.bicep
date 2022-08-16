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
        principalId: 'cdb31e36-4625-4a39-b7ac-980c970ba729'
      }
    ]
  }
}

