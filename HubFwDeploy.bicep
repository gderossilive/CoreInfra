// Resource Group
param location string 

// Virtual Network
param HubVnetName string 
param HubVnetAddressPrefix string 
param PEsubnetName string 
param PEsubnetAddressPrefix string


param Seed string 

var networkSecurityGroupName = 'NSG-${Seed}'

// -- NSG Deploy -- NSG deployment
module GeneralNSG 'src/NSG.bicep' = {
  name: networkSecurityGroupName
  params: {
    location: location
    NSGname: networkSecurityGroupName
  }
}

// -- NSG Deploy -- NSG link with PEsubnet
resource HubNSGVnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: HubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        HubVnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: PEsubnetName
        properties: {
          addressPrefix: PEsubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: GeneralNSG.outputs.NsgId
          }
        }
      }
    ]
  }
}

output HubVnetName string = HubVnetName
output PEsubnetName string = PEsubnetName
