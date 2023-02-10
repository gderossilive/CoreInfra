param VirtualNetGwName string
param GW_pip_name string = 'Onprem-GW-pip'
param VnetName string
param location string

var subnetName = 'GatewaySubnet'
var RgName = resourceGroup().name
var SubscriptionId = subscription().id
var resourceId = '/subscriptions/${SubscriptionId}/resourceGroups/${RgName}/providers/Microsoft.Network/virtualNetworkGateways/${VirtualNetGwName}/ipConfigurations/default'

resource VNGWiP 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: GW_pip_name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    publicIPAddressVersion: 'IPv4'
  }
}

resource VNet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: VnetName
}

resource Subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  parent: VNet
  name: subnetName
}

resource VirtualNetworkGW 'Microsoft.Network/virtualNetworkGateways@2022-07-01' = {
  name: VirtualNetGwName
  location: location
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: VNGWiP.id
          }
          subnet: {
            id: Subnet.id
          }
        }
      }
    ]
    natRules: []
    virtualNetworkGatewayPolicyGroups: []
    enableBgpRouteTranslationForNat: false
    disableIPSecReplayProtection: false
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    vpnGatewayGeneration: 'Generation1'
    allowRemoteVnetTraffic: false
    allowVirtualWanTraffic: false
  }
}

output VNetGwId string = VirtualNetworkGW.id
