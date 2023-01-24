# Introduzione
Ho sviluppato questo script per poter automatizzare il deployment degli scenari di base più comuni come:
- Una singola VNet con accesso ad internet controllato da firewall
- Un'architettura di rete di tipo Hub & Spoke con accesso diretto ad internet o controllato da firewall
- Un'architettura ibrida che vede una vlan collegata ad un'architettura di rete Hub & Spoke via vpn

Avere a disposizione velocemente questi ambienti, permette di potersi concentrare su scenari più complessi che si sviluppano sopra di questi, come ad esempio:
- Server Arc equipaggiati da una o più extensions 
- Studio del routing per risorse di tipo PaaS
- Etc.

Di seguito i template per il deployment degli scenari principali

| Scenario | Descrizione | ARM Template |
|:-------------------------|:-------------|:-------------|
| Singola VNet | VNet singola con traffico internet routato attraverso il firewall |[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgderossilive%2FCoreInfra%2Fmaster%2FARM%2FSingolaVNet.json)
| Hub & Spoke | Hub & Spoke con traffico internet routato attraverso il firewall |[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgderossilive%2FCoreInfra%2Fmaster%2FARM%2FHubAndSpoke.json)
| Hub & Spoke ibrido | Hub & Spoke + VLAN collegata via vpn, con traffico internet routato attraverso il firewall |[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgderossilive%2FCoreInfra%2Fmaster%2FARM%2FHybrid.json)

# Architettura
L'ambiente realizzato tramite questo script è articolato in 2 parti principali:

- Una parte che rappresenta una tipica architettura Hub&Spoke
- Una parte che può essere utilizzata per rappresentare una VLan OnPrem collegata con l'Hub

## Architettura Hub&Spoke


Prova a farne il deploy sulla tua sottoscrizione

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgderossilive%2FCoreInfra%2Fmaster%2FARM%2FSingolaVNet.json)