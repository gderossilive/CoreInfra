# Singola VNet Architecture

In questo primo scenario viene in realtà considerato solo l'Hub dell'architettura completa. Procederemo quindi alla descrizione di questa singola componente

![Architettura Singola VNet](https://raw.githubusercontent.com/gderossilive/CoreInfra/master/doc/SingolaVNet.jpg)
## Architettura dell'Hub VNet

L'Hub è composto da una VNet chiamata Hub-Vnet al cui interno sono organizzate le seguenti subnet:

- GatewaySubnet che ospita il Virtual Network Gateway utilizzato per instaurare la site-to-site VPN verso l'onprem
- AzureFirewallSubnet che ospita gli endpoint dell'Azure Fiewall utilizzato per regolare il traffico da e verso internet all'interno dell'intera piattaforma cloud
- AzureBastionSubnet che ospita gli endpoint del servizio Azure Bastion utilizzato per l'accesso sicuro a tutte le vm presenti in cloud ed onprem
- DNS-outbound e DNS-inbound che ospitano gli endpoint del servizio Azure DNS Resolver
- PE-Subnet utilizzata per ospitare eventuali private endpoint e VM

## Descrizone dei servizi utilizzati
[...]