// Example CLI usage
// az deployment group create -g rg-hub-scu-demo -f ./nva.bicep --param spokeName='hub-scu' --param adminUser='yourname'

@description('Required. Name of this spoke')
param spokeName string

@description('Optional. Azure location to deploy this hub. Defaults to deployment location')
param targetLocation string = resourceGroup().location

@description('Optional. Type of subscription (e.g. dev, prod, demo)')
param subscriptionType string = 'demo'

@secure()
param adminPassword string = ''

param adminUser string

targetScope = 'resourceGroup'
var targetResourceGroup = resourceGroup()
var adminPubKey = loadTextContent('../../.ssh/id_rsa.pub')

var tags = {
  ApplicationName: spokeName
  BusinessUnit: 'MCAPS'
  DisasterRecovery: 'Non-Essential'
  Environment: subscriptionType
  Owner: 'Michael Burch'
  ServiceClass: subscriptionType
  CreatedWith: 'bicep'
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: 'vnet-hub-scu-demo'
  scope: targetResourceGroup
}

module nva 'modules/compute/virtualMachines/main.bicep' = {
  name: 'vm-nva-${spokeName}-${subscriptionType}'
  scope: targetResourceGroup
  params: {
    name: 'vm-nva-${spokeName}-${subscriptionType}'
    adminUsername: adminUser
    adminPassword: adminPassword
    encryptionAtHost: false
    disablePasswordAuthentication: empty(adminPassword)
    bootDiagnostics: true
    publicKeys: [
      { keyData: adminPubKey
        path: '/home/michael/.ssh/authorized_keys' }
    ]
    location: targetLocation
    imageReference: {
      publisher: 'thefreebsdfoundation'
      offer: 'freebsd-13_1'
      sku: '13_1-release'
      version: 'latest'
    }
    plan: {
      name: '13_1-release'
      publisher: 'thefreebsdfoundation'
      product: 'freebsd-13_1'
    }
    nicConfigurations: [
      {
        nicSuffix: '-nic'
        enableIPForwarding: true
        enableAcceleratedNetworking: false
        ipConfigurations: [ {
            name: 'wanipconfig'
            subnetResourceId: vnet.properties.subnets[1].id
            pipconfiguration: {
              publicIpNameSuffix: '-pip'
              tags: tags }
          } ]
      }
      {
        nicSuffix: '-nic'
        enableIPForwarding: true
        enableAcceleratedNetworking: false
        ipConfigurations: [ {
            name: 'lanipconfig'
            subnetResourceId: vnet.properties.subnets[2].id
          } ]
      }
    ]
    osDisk: {
      caching: 'ReadWrite'
      createOption: 'FromImage'
      managedDisk: {
        storageAccountType: 'Standard_LRS'
      }
    }
    extensionCustomScriptConfig: {
      // FreeBSD is not supported for CustomScriptExtension versions greater than 1.x
      // https://learn.microsoft.com/en-us/azure/virtual-machines/linux/freebsd-intro-on-azure
      enabled: true
      publisher: 'Microsoft.OSTCExtensions'
      type: 'CustomScriptForLinux'
      typeHandlerVersion: '1.5.5'
      autoUpgradeMinorVersion: false
      fileData: [
        {
          uri: 'https://raw.githubusercontent.com/michaelburch/azure-opnsense/main/install-opnsense.sh'
        }
      ]
      commandToExecute:'sh install-opnsense.sh'
    }
    osType: 'Linux'
    vmSize: 'standard_b2s'
  }
}
