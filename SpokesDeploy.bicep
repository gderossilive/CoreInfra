targetScope='subscription'
// Virtual Network
param HubVnetName string 

// Resource Group
param HubRGname string
param SpokeRGname string
param location string 

param Seed string
param Spokes int = 1
param DeployRT bool
param DeployNSG bool
param DeployDNS bool
param FwIP string
param CustomDNSserverAddress string

resource HubRG 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: HubRGname
}

resource SpokesRG 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: SpokeRGname
}

module SpokesVnet 'src/SpokeVNetwork.bicep' = [for i in range(0,Spokes): {
  name: 'Spoke-VNet-${i}'
  scope: SpokesRG
  params: {
    virtualNetworkName: 'Spoke-VNet-${i}'
    vnetAddressPrefix: '10.20.${i}.0/24'
    PEsubnetName:  'PEsubnet-${i}-${Seed}'
    PEsubnetAddressPrefix: '10.20.${i}.0/24'
    GatewaySubnetAddressPrefix: ''
    NSGname: 'NSG-${i}-${Seed}'
    FwIP: FwIP
    location: location
    CustomDNSserver: CustomDNSserverAddress
    DeployGw: false
    DeployRT: DeployRT
    DeployNSG: DeployNSG
    DeployDNS: DeployDNS
  }
}]

module Hub2Spoke './src/NetworkPeering.bicep' = [for i in range(0,Spokes): {
  dependsOn: [
    SpokesVnet
  ]
  name: 'Hub2Spoke-${i}'
  scope: HubRG
  params: {
    virtualNetworkName: HubVnetName
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    useRemoteGateways: false 
    remoteResourceGroup: SpokeRGname
    remoteVirtualNetworkName: 'Spoke-VNet-${i}'
  }
}]

module Spoke2Hub './src/NetworkPeering.bicep' = [for i in range(0,Spokes): {
  dependsOn: [
    SpokesVnet
  ]
  name: 'Spoke2Hub-${i}'
  scope: SpokesRG
  params: {
    virtualNetworkName: 'Spoke-VNet-${i}'
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    useRemoteGateways: false 
    remoteResourceGroup: HubRGname
    remoteVirtualNetworkName: HubVnetName
  }
}]


output SpokesVnetName array = [for i in range(0,Spokes): {
  name: SpokesVnet[i].outputs.virtualNetworkName
}]
output SpokesNsgName array = [for i in range(0,Spokes): {
  name: SpokesVnet[i].outputs.NsgName
}]
