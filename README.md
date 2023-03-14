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

| Scenario | Descrizione | ARM Template |
|:-------------------------|:-------------|:-------------|
| Singola VNet | VNet singola con traffico internet routato attraverso il firewall |[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgderossilive%2FCoreInfra%2Fmaster%2FARM%2FSingolaVNet.json)
| Hub & Spoke | Hub & Spoke con traffico internet routato attraverso il firewall |[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgderossilive%2FCoreInfra%2Fmaster%2FARM%2FHubAndSpoke.json)
| Hub & Spoke ibrido | Hub & Spoke + VLAN collegata via vpn, con traffico internet routato attraverso il firewall |[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgderossilive%2FCoreInfra%2Fmaster%2FARM%2FHybrid.json)

## Azure CLI
E' possibile fare il deployment dei 3 scenari anche utilizzando Azure CLI. Prima di lanciare uno qualsiasi dei tre scenari, è consigliabile instanziare le 4 variabili sotto 
```
$Seed=(-join ((48..57) + (97..122) | Get-Random -Count 3 | % {[char]$_}))
$MyIP=<Inserisci il tuo IP>
$location='eastus'
$adminPassword=(-join ((48..59) + (63..91) + (99..123) | Get-Random -count 15 | % {[char]$_})) 
$MyObecjectId=<Inserisci l'objectId del tuo utente> 
$SpokesNumber=0
```
### Scenario Singola VNet 
```
az deployment sub create `
  --name "CoreMain-$Seed" `
  --location eastus `
  --template-uri "https://raw.githubusercontent.com/gderossilive/CoreInfra/master/ARM/SingolaVNet.json"  `
  --parameters `
        https://raw.githubusercontent.com/gderossilive/CoreInfra/master/Parameters.json `
        Seed=$Seed `
        MyObjectId=$MyObecjectId `
        MyIP=$MyIP `
        adminPassword=$adminPassword
```
### Scenario Hub&Spoke
```
az deployment sub create `
  --name "CoreMain-$Seed" `
  --location eastus `
  --template-uri "https://raw.githubusercontent.com/gderossilive/CoreInfra/master/ARM/HubAndSpoke.json"  `
  --parameters `
        https://raw.githubusercontent.com/gderossilive/CoreInfra/master/Parameters.json `
        Seed=$Seed `
        MyObjectId=$MyObecjectId `
        MyIP=$MyIP `
        adminPassword=$adminPassword
```
### Scenario hybrid 
```
az deployment sub create `
  --name "CoreMain-$Seed" `
  --location eastus `
  --template-uri "https://raw.githubusercontent.com/gderossilive/CoreInfra/master/ARM/Hybrid.json"  `
  --parameters `
        https://raw.githubusercontent.com/gderossilive/CoreInfra/master/Parameters.json `
        Seed=$Seed `
        MyObjectId=$MyObecjectId `
        MyIP=$MyIP `
        adminPassword=$adminPassword
```
### Cattura dei parametri di output
[...]

# Architettura
Questa soluzione è basata sulla blueprint ["Azure Security Benchmark Foundation"](https://learn.microsoft.com/en-us/azure/governance/blueprints/samples/azure-security-benchmark-foundation/) che fornisce una serie di pattern per la costruzione di un'ambiente sicuro su Azure. Proprio per questo:
- prevede l'utilizzo di User Defined Route (UDR) per convogliare sempre il traffico in uscita su internet verso un firewall
- utilizza Network Security Group (NSG) per regolare il traffico in ingresso ed in uscita dalle diverse subnet
- non permette l'accesso diretto a VM tramite indirizzo IP pubblico, ma solo mediato da Azure Bastion
- utilizza un Key Vault per custodire i secret ed i certificati
- fornisce un DNS Resolver per facilitare l'adozione di private endpoint per le risorse PaaS 
- l'uscita su internet del traffico on-prem è anch'esso generalmente mediato da un proxy (Squid)

L'architettura completa della soluzione è rappresentata nella figura sotto
![Architettura completa](https://github.com/gderossilive/CoreInfra/blob/master/doc/hybrid.jpg?raw=true "Architettura Completa")
dove è possibile riconoscere 1 Hub, 2 Spoke e una VLAN onprem collegata all'Hub attraverso una VPN site-to-site.

## Architettura dell'Hub
L'Hub è composto da una VNet chiamata Hub-Vnet al cui interno sono organizzate le seguenti subnet:
- GatewaySubnet che ospita il Virtual Network Gateway utilizzato per instaurare la site-to-site VPN verso l'onprem
- AzureFirewallSubnet che ospita gli endpoint dell'Azure Fiewall utilizzato per regolare il traffico da e verso internet all'interno dell'intera piattaforma cloud
- AzureBastionSubnet che ospita gli endpoint del servizio Azure Bastion utilizzato per l'accesso sicuro a tutte le vm presenti in cloud ed onprem
- DNS-outbound e DNS-inbound che ospitano gli endpoint del servizio Azure DNS Resolver
- PE-Subnet utilizzata per ospitare eventuali private endpoint e VM 

## Architettura degli Spoke
[...]

## Architettura dell'OnPrem
[...]