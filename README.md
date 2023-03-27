# Introduzione
Ho sviluppato questo script per poter automatizzare il deployment degli scenari di base più comuni come:
- Una singola VNet con accesso ad internet controllato da firewall
- Un'architettura di rete di tipo Hub & Spoke con accesso diretto ad internet o controllato da firewall
- Un'architettura ibrida che vede una vlan collegata ad un'architettura di rete Hub & Spoke via vpn

Avere a disposizione velocemente questi ambienti, permette di potersi concentrare su scenari più complessi che si sviluppano sopra di questi, come ad esempio:
- Server Arc equipaggiati da una o più extensions 
- Studio del routing per risorse di tipo PaaS
- Etc.

# Deployment
## Azure Button

| Scenario | Descrizione | Azure Portal UI | Command Line (Bicep) | Link |
|:-------------------------|:-------------|:--------------------------:|:----------------------: |:------------- |
| Singola VNet | VNet singola con traffico internet routato attraverso il firewall  |<div style="width:200px">[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgderossilive%2FCoreInfra%2Fmaster%2FARM%2FSingolaVNet.json)</div>| <div style="width:50px">[![Powershell/Azure CLI](https://github.com/gderossilive/CoreInfra/blob/master/doc/powershell_small.png?raw=true)](https://github.com/gderossilive/CoreInfra/blob/master/doc/DeploySingolaVNet.md)</div>| [Descrizione di dettaglio](https://github.com/gderossilive/CoreInfra/blob/master/doc/ArchSingolaVNet.md)|
| Hub & Spoke | Hub & Spoke con traffico internet routato attraverso il firewall |<div style="width:200px">[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgderossilive%2FCoreInfra%2Fmaster%2FARM%2FHubAndSpoke.json)</div> |<div style="width:50px">[![Powershell/Azure CLI](https://github.com/gderossilive/CoreInfra/blob/master/doc/powershell_small.png?raw=true)](https://github.com/gderossilive/CoreInfra/blob/master/doc/DeployHubAndSpoke.md)</div>|[Descrizione di dettaglio](https://github.com/gderossilive/CoreInfra/blob/master/doc/ArchHubAndSpoke.md)|
| Hub & Spoke ibrido | Hub & Spoke + VLAN collegata via vpn, con traffico internet routato attraverso il firewall |<div style="width:200px">[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgderossilive%2FCoreInfra%2Fmaster%2FARM%2FHybrid.json)</div>|<div style="width:50px">[![Powershell/Azure CLI](https://github.com/gderossilive/CoreInfra/blob/master/doc/powershell_small.png?raw=true)](https://github.com/gderossilive/CoreInfra/blob/master/doc/DeployHybrid.md)</div>|[Descrizione di dettaglio](https://github.com/gderossilive/CoreInfra/blob/master/doc/ArchHybrid.md)|

# Architettura
Questa soluzione è basata sulla blueprint ["Azure Security Benchmark Foundation"](https://learn.microsoft.com/en-us/azure/governance/blueprints/samples/azure-security-benchmark-foundation/) che fornisce una serie di pattern per la costruzione di un'ambiente sicuro su Azure. Proprio per questo:
- prevede l'utilizzo di User Defined Route (UDR) per convogliare sempre il traffico in uscita su internet verso un firewall
- utilizza Network Security Group (NSG) per regolare il traffico in ingresso ed in uscita dalle diverse subnet
- non permette l'accesso diretto a VM tramite indirizzo IP pubblico, ma solo mediato da Azure Bastion
- utilizza un Key Vault per custodire i secret ed i certificati
- fornisce un DNS Resolver per facilitare l'adozione di private endpoint per le risorse PaaS 
- l'uscita su internet del traffico on-prem è anch'esso generalmente mediato da un proxy (Squid)

L'architettura completa della soluzione è rappresentata nella figura sotto
![Architettura completa](https://raw.githubusercontent.com/gderossilive/CoreInfra/master/doc/Completa.jpg "Architettura Completa")
dove è possibile riconoscere 1 Hub, 2 Spoke e una VLAN onprem collegata all'Hub attraverso una VPN site-to-site.

Da questa architettura è possibile poi "ritagliare" quelle relative agli scenari elencati in precedenza:
- [Singola VNet](https://github.com/gderossilive/CoreInfra/blob/master/doc/SingolaVNet.md)
- [Hub & Spoke](https://github.com/gderossilive/CoreInfra/blob/master/doc/HubAndSpoke.md)
- [Ibrido (Cloud + OnPrem)](https://github.com/gderossilive/CoreInfra/blob/master/doc/Hybrid.md) 