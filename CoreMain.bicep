targetScope='subscription'

// General parameters
param Seed string
param MyIP string
param Location string
@secure()
param adminPassword string

// Hub parameters
param HubRgPostfix string
param HubVnetPrefix string
param InSubnetPrefix string
param OutSubnetPrefix string
param PEsubnetName string
param HubVnetAddressPrefix string
param CustomDNSserver string
param DNSInboundSubnetAddressPrefix string
param DNSOutboundSubnetAddressPrefix string
param BastionSubnetAddressPrefix string
param PEsubnetAddressPrefix string
param FirewallSubnetAddressPrefix string
param GatewaySubnetAddressPrefix string


param DeployNSG bool
param DeployRT bool
param DeployBS bool
param DeployDNS bool
param DeployKV bool

// Spoke parameters
param SpokeRgPostfix string
param SpokesNumber int = 0

// OnPrem parameters
param DeployOnPrem bool 
param DeployProxy bool 
param OnPremRgPostfix string
param MyObjectId string 
param OnPremVnetPrefix string 
param OnPremVnetAddressPrefix string 
param OnPremGWvnetSubnetAddressPrefix string 
param OnPremPEvnetSubnetAddressPrefix string
param OnPremDMZvnetSubnetAddressPrefix string


var HubRgName = '${Seed}-${HubRgPostfix}'
var HubVnetName = '${HubVnetPrefix}-${Seed}'
var InSubnetName = '${InSubnetPrefix}-${Seed}'
var OutSubnetName = '${OutSubnetPrefix}-${Seed}'
var NSGname = 'NSG-${Seed}'
var RouteTabelName = 'RT-${Seed}'
var SpokeRgName = '${Seed}-${SpokeRgPostfix}'
var OnPremRGname = '${Seed}-${OnPremRgPostfix}'
var OnPremVnetName = '${OnPremVnetPrefix}-${Seed}'
var ProxyName = 'Proxy-${Seed}'


// Hub Resource Group Deploy
resource HubRG 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: HubRgName
  location: Location
}
 
module HubDeploy 'HubDeploy.bicep' = {
  name: 'HubEssentialDeploy-${Seed}'
  scope: HubRG
  params: {
    HubVnetName: HubVnetName
    HubVnetAddressPrefix: HubVnetAddressPrefix
    PEsubnetName: PEsubnetName
    PEsubnetAddressPrefix: PEsubnetAddressPrefix
    BastionSubnetAddressPrefix: BastionSubnetAddressPrefix
    DNSInboundSubnetAddressPrefix: DNSInboundSubnetAddressPrefix
    DNSOutboundSubnetAddressPrefix: DNSOutboundSubnetAddressPrefix
    FirewallSubnetAddressPrefix: FirewallSubnetAddressPrefix
    GatewaySubnetAddressPrefix: GatewaySubnetAddressPrefix
    InSubnetName: InSubnetName
    OutSubnetName: OutSubnetName
    NSGname: NSGname
    RouteTableName: RouteTabelName
    MyIPaddress: MyIP
    MyObjectId: MyObjectId
    adminPassword: adminPassword
    location: Location
    Seed: Seed
    DeployBS: DeployBS
    DeployDNS: DeployDNS
    DeployNSG: DeployNSG
    DeployRT: DeployRT
    DeployKV: DeployKV
  }
}

resource SpokeRG 'Microsoft.Resources/resourceGroups@2021-01-01' = if (SpokesNumber>0) {
  name: SpokeRgName
  location: Location
}

module SpokesDeploy 'SpokesDeploy.bicep' = if (SpokesNumber>0) {
  name: 'SpokesDeploy-${Seed}'
  params: {
    CustomDNSserverAddress: HubDeploy.outputs.DNSIp
    DeployRT: DeployRT
    DeployNSG: DeployNSG
    DeployDNS: DeployDNS
    FwIP: DeployRT ? HubDeploy.outputs.FwIp : '' 
    HubRGname: HubRgName
    HubVnetName: HubVnetName
    location: Location
    Seed: Seed
    SpokeRGname: SpokeRgName
    Spokes: SpokesNumber
  }
}

module OnPremDeploy 'OnPremDeploy.bicep' = if (DeployOnPrem) {
  name: 'OnPremDeploy-${Seed}'
  params: {
    adminPassword: adminPassword
    CustomDNSserverAddress: HubDeploy.outputs.DNSIp
    DeployProxy: DeployProxy
    HubRGname: HubRgName
    HubVnetName: HubVnetName
    location: Location
    MyIPaddress: MyIP
    MyObjectId: MyObjectId
    OnPremGWvnetSubnetAddressPrefix: OnPremGWvnetSubnetAddressPrefix
    OnPremPEvnetSubnetAddressPrefix: OnPremPEvnetSubnetAddressPrefix
    OnPremDMZvnetSubnetAddressPrefix: OnPremDMZvnetSubnetAddressPrefix
    OnPremRGname: OnPremRGname
    OnPremVnetAddressPrefix: OnPremVnetAddressPrefix
    OnPremVnetName: OnPremVnetName
    RulesetName: HubDeploy.outputs.RulesetName
    Seed: Seed
    FwIP: DeployRT ? HubDeploy.outputs.FwIp : ''
  }
}

// Hub outputs
output HubRgName string = HubRgName
output HubVNetName string = HubDeploy.outputs.HubVnetName
output DnsIp string = (DeployDNS) ? HubDeploy.outputs.DNSIp : ''
output FwName string = (DeployRT) ? HubDeploy.outputs.FwName : ''
output RulesetName string = (DeployDNS) ? HubDeploy.outputs.RulesetName : ''
output KvName string = (DeployKV) ? HubDeploy.outputs.KvName : ''
output PEsubnetName string = HubDeploy.outputs.PEsubnetName


// Spoke outputs
output SpokeRGname string = (SpokesNumber > 0) ? SpokeRgName: ''
output SpokesVnetNames array = (SpokesNumber > 0) ? SpokesDeploy.outputs.SpokesVnetName : []

// OnPrem outputs
output OnPremRGname string = (DeployOnPrem) ? OnPremRGname: ''
output OnpremVNetName string = (DeployOnPrem) ? OnPremDeploy.outputs.OnPremVnetName : ''
output ProxyName string = (DeployProxy) ? OnPremDeploy.outputs.ProxyName : ''
output DMZsubnetName string = (DeployOnPrem) ? OnPremDeploy.outputs.DMZsubnetName: ''

