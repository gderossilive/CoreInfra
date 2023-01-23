param RTname string
param location string = resourceGroup().location
param disableBgpRoutePropagation bool = false
param FwIP string

resource RT 'Microsoft.Network/routeTables@2021-08-01' = {
  name: RTname
  location: location
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: []
  }
}

resource route2fw 'Microsoft.Network/routeTables/routes@2021-08-01' = {
  name: '${RTname}/ToFW'
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

output RTid string = RT.id
