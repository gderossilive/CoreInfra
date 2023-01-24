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
Dopodichè lanciare il comando Azure CLI corrispondente allo scenario che si vuole realizzare
```
# Scenario Singola VNet 
az deployment sub create `
  --name "CoreMain-$Seed" `
  --location eastus `
  --template-uri "https://raw.githubusercontent.com/gderossilive/CoreInfra/master/ARM/SingolaVNet.json"  `
  --parameters `
        Seed=$Seed `
        MyObjectId=$MyObecjectId `
        MyIP=$MyIP `
        adminPassword=$adminPassword

# Scenario Hub&Spoke
az deployment sub create `
  --name "CoreMain-$Seed" `
  --location eastus `
  --template-uri "https://raw.githubusercontent.com/gderossilive/CoreInfra/master/ARM/HubAndSpoke.json"  `
  --parameters `
        Seed=$Seed `
        MyObjectId=$MyObecjectId `
        MyIP=$MyIP `
        adminPassword=$adminPassword

# Scenario hybrid 
az deployment sub create `
  --name "CoreMain-$Seed" `
  --location eastus `
  --template-uri "https://raw.githubusercontent.com/gderossilive/CoreInfra/master/ARM/Hybrid.json"  `
  --parameters `
        Seed=$Seed `
        MyObjectId=$MyObecjectId `
        MyIP=$MyIP `
        adminPassword=$adminPassword
```

# Architettura
[...]