// General
param location string = resourceGroup().location
param Seed string
param MyObjectId string
@secure()
param adminPassword string

param CustomDNSserver string = '10.10.0.4'
param NSGname string 
param RouteTableName string
param disableBgpRoutePropagation bool = false
param MyIPaddress string 

// Virtual Network
param HubVnetName string 
param HubVnetAddressPrefix string 
param InSubnetName string 
param OutSubnetName string
param PEsubnetName string
param DNSInboundSubnetAddressPrefix string
param DNSOutboundSubnetAddressPrefix string
param BastionSubnetAddressPrefix string
param PEsubnetAddressPrefix string
param FirewallSubnetAddressPrefix string
param GatewaySubnetAddressPrefix string

// Deployment switches
param DeployNSG bool
param DeployRT bool
param DeployBS bool
param DeployDNS bool
param DeployKV bool

var FwName = 'AzFW-${Seed}'
// The name of the Bastion public IP address
var publicIpName  = 'pip-bastion-${Seed}'
// The name of the Bastion host
var bastionHostName = 'bastion-jumpbox-${Seed}'
var ResolverName = 'DNS-${Seed}'
var RulesetName = 'RS-${Seed}'
var NetworkLinkName = '${HubVnetName}-link'
var KVname = 'KV-${Seed}'

resource NSG 'Microsoft.Network/networkSecurityGroups@2021-02-01' = if (DeployNSG || DeployRT) {
  name: NSGname
  location: location
  properties: {
    securityRules: []
  }
}

resource BastionNSG 'Microsoft.Network/networkSecurityGroups@2021-02-01' = if (DeployBS) {
  name: 'Bastion-${NSGname}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 200
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes:[]
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes:[]
        }
      }
      {
        name: 'AllowHttpsInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: MyIPaddress
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes:[]
        }
      }
      {
        name: 'AllowSshRdpOutbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: [
            '22'
            '3389'
          ]
          sourceAddressPrefixes: []
          destinationAddressPrefixes:[]
        }
      }
    ]
  }
}

resource RT 'Microsoft.Network/routeTables@2021-08-01' = if (DeployRT) {
  name: RouteTableName
  location: location
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: []
  }
}

resource route2fw 'Microsoft.Network/routeTables/routes@2021-08-01' = if (DeployRT) {
  name: '${RouteTableName}/ToFW'
  dependsOn: [
    RT
  ]
  properties: {
    addressPrefix: '0.0.0.0/0'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: DeployRT ? AzFW.outputs.FwIP : ''
    hasBgpOverride: false
  }
}

// Hub Virtual Network Deploy
resource HubVNet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: HubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        HubVnetAddressPrefix
      ]
    }
    dhcpOptions: { dnsServers: (DeployDNS) ? [CustomDNSserver] : null
    }
    subnets: [
      {
        name: InSubnetName
        properties: {
          addressPrefix: DNSInboundSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
//          networkSecurityGroup: (DeployNSG) ? {id:NSG.id} : null
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
      {
        name: OutSubnetName
        properties: {
          addressPrefix: DNSOutboundSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
//          networkSecurityGroup: (DeployNSG) ? {id:NSG.id} : null
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: BastionSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: (DeployBS) ? {id:BastionNSG.id} : null
        }
      }
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
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: FirewallSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: GatewaySubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}


resource DisableAzureCloudOutbound 'Microsoft.Network/networkSecurityGroups/securityRules@2021-08-01' = if (DeployRT) {
  dependsOn: [
    HubVNet
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

module AzFW 'src/AzFW.bicep' = if (DeployRT) {
  name: FwName
  params: {
    virtualNetworkName: HubVNet.name
    Seed: Seed
    location: location
  }
}

resource publicIpAddressForBastion 'Microsoft.Network/publicIpAddresses@2020-08-01' = if (DeployBS) {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  name: '${HubVnetName}/AzureBastionSubnet'
}


resource bastionHost 'Microsoft.Network/bastionHosts@2022-01-01' = if (DeployBS) {
  name: bastionHostName
  dependsOn: [
    HubVNet
  ]
  location: location
  sku:{
    name: 'Standard'
  }
  properties: {
    enableIpConnect: true
    disableCopyPaste: false
    scaleUnits: 2
    enableTunneling: false
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionSubnet.id
          }
          publicIPAddress: {
            id: publicIpAddressForBastion.id
          }
        }
      }
    ]
  }
}

resource Resolver 'Microsoft.Network/dnsResolvers@2020-04-01-preview' = if (DeployDNS || DeployKV) {
  name: ResolverName
  location: location
  properties: {
    virtualNetwork: {
      id: HubVNet.id
    } 
  }
}

resource InboundSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  name: '${HubVnetName}/${InSubnetName}'
}

resource InboundEndpoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2020-04-01-preview' = if (DeployDNS || DeployKV) {
  dependsOn: [
    Resolver
  ]
  name: '${ResolverName}/${InSubnetName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        subnet: {
          id: InboundSubnet.id
        }
        privateIpAllocationMethod: 'Dynamic'
      }
    ]
  }
}

resource OutboundSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = if (DeployDNS || DeployKV) {
  name: '${HubVnetName}/${OutSubnetName}'
}

resource OutboundEndpoint 'Microsoft.Network/dnsResolvers/outboundEndpoints@2020-04-01-preview' = if (DeployDNS || DeployKV) {
  dependsOn: [
    Resolver
    InboundEndpoint
  ]
  name: '${ResolverName}/${OutSubnetName}'
  location: location
  properties: {
    subnet: {
      id: OutboundSubnet.id
    }
  }
}

resource Ruleset 'Microsoft.Network/dnsForwardingRulesets@2020-04-01-preview' = if (DeployDNS || DeployKV) {
  dependsOn: [
    InboundEndpoint
  ]
  name: RulesetName
  location: location
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: OutboundEndpoint.id
      }
    ]
  }
}

resource VnetLink 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2020-04-01-preview' = if (DeployDNS || DeployKV) {
  dependsOn: [
    Ruleset
  ]
  name: '${RulesetName}/${NetworkLinkName}'
  properties: {
    virtualNetwork: {
      id: HubVNet.id
    }
  }
}

module KV './src/KV.bicep' = if (DeployKV) {
  dependsOn: [
    Ruleset
  ]
  name: KVname
  params: {
    keyVaultName: KVname
    objectId: MyObjectId
    VnetName: HubVnetName
    SubnetName: PEsubnetName
    MyIPaddress: MyIPaddress
    RulesetName: RulesetName
    location: location
  }
}

resource adminPsswd 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = if (DeployKV) {
  dependsOn: [
    Ruleset
    KV
  ]
  name: '${KVname}/adminPassword'
  properties: {
    value: adminPassword
  }
}

output HubVnetName string = HubVnetName
output PEsubnetName string = PEsubnetName
output DNSIp string = DeployDNS ? InboundEndpoint.properties.ipConfigurations[0].privateIpAddress : ''
output RulesetName string = DeployDNS ? RulesetName : ''
output FwIp string = DeployRT ? AzFW.outputs.FwIP : ''
output FwName string = DeployRT ? AzFW.outputs.AzFwName : ''
output KvName string = DeployKV ? KVname : ''
