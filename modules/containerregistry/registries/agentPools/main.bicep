@description('Conditional. The name of the parent registry. Required if the template is used in a standalone deployment.')
param registryName string

@description('Required. The name of the agent pool.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Desired Number of agents (VMs) specified for the pool. The default value is 0.')
@minValue(0)
param count int = 0

@description('Optional. The operating system type. The default is Linux.')
@allowed([
  'Linux'
  'Windows'
])
param osType string = 'Linux'

@description('Optional. Tier size availability varies by region. For more details agent pool tiers, see: azure/container-registry/tasks-agent-pools.')
@allowed([
  'S1'
  'S2'
  'S3'
  'I6'
])
param tier string = 'S1'

@description('Optional. Agent Pool Subnet ID. The ID of a subner where all agents in the pool will be placed.')
param vnetSubnetId string = ''

resource registry 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  name: registryName
}

resource agentpool 'Microsoft.ContainerRegistry/registries/agentPools@2019-06-01-preview' = {
  name: name
  parent: registry
  location: location
  tags: tags
  properties: {
    os: osType
    count: count
    virtualNetworkSubnetResourceId: vnetSubnetId
    tier: tier
  }
}

@description('The name of the agent pool.')
output name string = agentpool.name

@description('The resource ID of the agent pool.')
output resourceId string = agentpool.id

@description('The name of the resource group the replication was created in.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = agentpool.location
