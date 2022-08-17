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
        roleDefinitionIdOrName: 'AcrPull'
        principalId: '835025d5-2679-4dec-b5f9-5d7c2a30811d'
      }
    ]
  }
}
