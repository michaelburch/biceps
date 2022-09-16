targetScope = 'subscription'
var spokeName = 'notary'
var targetResourceGroup = spokeName
param targetLocation string = deployment().location

var tags = {
  createdWith: 'bicep'
  project: spokeName
}

module rg 'br:biceps.azurecr.io/modules/resources/resourcegroups:v0.6.0' = {
  name: targetResourceGroup
  params: {
    location: targetLocation
    name: targetResourceGroup
    tags: tags
  }
}

module vnet 'br:biceps.azurecr.io/modules/network/virtualnetworks:v0.6.0' = {
  name: '${spokeName}-vnet'
  scope: resourceGroup(rg.name)
  params: {
    name: '${spokeName}-vnet'
    addressPrefixes: [
      '192.168.64.0/24'
      '192.168.65.0/24'
    ]
    subnets: [
      {
        name: 'pe-subnet'
        addressPrefix: '192.168.64.0/27'
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'aks-subnet'
        addressPrefix: '192.168.65.0/24'
        privateEndpointNetworkPolicies: 'Enabled'
      }
    ]
  }
}

module kv 'br:biceps.azurecr.io/modules/keyvault/vaults:v0.6.0' = {
  name: '${spokeName}-kv'
  scope: resourceGroup(rg.name)
  params: {
    name: '${spokeName}-kv'
    publicNetworkAccess: 'Disabled'
    enableRbacAuthorization: true
    privateEndpoints: [
      {
        service: 'vault'
        subnetResourceId: vnet.outputs.subnetResourceIds[0]
        tags: tags
      }
    ]
  }
}

module acr 'br:biceps.azurecr.io/modules/containerregistry/registries:v0.6.0' = {
  name: '${spokeName}-acr'
  scope: resourceGroup(rg.name)
  params: {
    name: '${spokeName}acr'
    publicNetworkAccess: 'Disabled'
    acrSku: 'Premium'
    privateEndpoints: [
      {
        service: 'registry'
        subnetResourceId: vnet.outputs.subnetResourceIds[0]
        tags: tags
      }
    ]
  }
}
