param virtualNetworkName string
param vnetAddressPrefix string 

param PEsubnetName string 

param PEsubnetAddressPrefix string 
param GatewaySubnetAddressPrefix string 
param FwIP string

param CustomDNSserver string 
param NSGname string
param DeployGw bool 
param DeployRT bool
param DeployNSG bool
param DeployDNS bool
param location string = resourceGroup().location

resource NSG 'Microsoft.Network/networkSecurityGroups@2021-02-01' = if (DeployNSG) {
  name: NSGname
  location: location
  properties: {
    securityRules: []
  }
}

resource RT 'Microsoft.Network/routeTables@2021-08-01' = if(DeployRT) {
  name: 'SpokeRT'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: []
  }
}

resource route2fw 'Microsoft.Network/routeTables/routes@2021-08-01' = if(DeployRT) {
  name: 'SpokeRT/ToFW'
  dependsOn: [
    RT
  ]
  properties: {
    addressPrefix: '0.0.0.0/0'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: FwIP
    hasBgpOverride: false
  }
}

resource DisableAzureCloudOutbound 'Microsoft.Network/networkSecurityGroups/securityRules@2021-08-01' = if (DeployRT) {
  dependsOn: [
    NSG
  ]
  name: '${NSGname}/NoInternetHub'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: 'Internet'
    access: 'Deny'
    priority: 1000
    direction: 'Outbound'
    sourcePortRanges: []
    destinationPortRanges: ['443','80']
    sourceAddressPrefixes:  []
    destinationAddressPrefixes:  []
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    dhcpOptions: { dnsServers: (DeployDNS) ? [CustomDNSserver] : null}
    subnets: [
      {
        name: PEsubnetName
        properties: {
          addressPrefix: PEsubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: (DeployNSG) ? {id:NSG.id} : null
          routeTable: (DeployRT) ? {id:RT.id} : null
        }
      }
    ]
  }
}

resource GwSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = if (DeployGw) {
  name: 'GatewaySubnet'
  parent: vnet
  properties: {
    addressPrefix: GatewaySubnetAddressPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}


output virtualNetworkRg string = resourceGroup().name
output virtualNetworkName string = virtualNetworkName
output NsgName string = NSGname
