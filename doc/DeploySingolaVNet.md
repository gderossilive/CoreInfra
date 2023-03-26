# Deployment Steps (AZ CLI) default

- All'interno del file Parameter.json sono stati già stati instaziati tutti i parametri necessari alla creazione dello scenario, a meno dei 4 parametri di seguito che bisognerà necessariamente instaziare

```azcli
    $Seed=(-join ((48..57) + (97..122) | Get-Random -Count 3 | % {[char]$_}))
    $MyIP=<Inserisci il tuo IP>
    $location=<Inserisci la region di riferimento>
    $adminPassword=(-join ((48..59) + (63..91) + (99..123) | Get-Random -count 15 | % {[char]$_})) 
    $MyObecjectId=<Inserisci l'objectId del tuo utente> 
    $SpokesNumber=0
```

- Fatto questo si può procedere a fare login ad Azure tramite il comando

```azcli
    az login
```

- Posizionarsi nella sottoscrizione di riferimento

```azcli
    az account set --subscription <ResourceId della tua sottoscrizione>
```

- lanciare il deployment dello scenario attraverso il comando

```azcli
    az deployment sub create `
      --name "CoreMain-$Seed" `
      --location $location `
      --template-file "SingolaVNet.json"  `
      --parameters `
            Parameters.json `
            Seed=$Seed `
            MyObjectId=$MyObecjectId `
            MyIP=$MyIP `
            adminPassword=$adminPassword
```

# Deployment Steps (AZ CLI) personalizzato

Prima di lanciare il deployment dello scenario, è consigliabile:

- Clonare questo repository sull'Azure Cloud Shell o in locale
- Personalizzare i parametri nel file Parameters.json.
  - Di seguito i parametri utili a definire quali componenti vengono coinvolti nel deployment dello scenario SingleVNet

    | Parametro | Default | Descrizione |
    |:--------- |:------- |:----------- |
    | DeployRT  | True    | Utilizzare UDR per ruotare il traffico verso NVA |
    | DeployNSG | True | Utilizzare NSG per filtrare il traffico della PEsubnet |
    | SpokesNumber | 0 | Da utilizzare per scenari Hub & Spoke |
    | DeployBS | False | Da utilizzare per accedere ad eventuali VM create nella VNet|
    | DeployDNS | False | Da utilizzare se si prevede la presenza di private endpoint nella VNet |
    | DeployKV | False | Da utilizzare per proteggere password di eventuali VM create nella VNet|
    | DeployOnPrem | False | Da utilizzare in scenari ibridi per simulare rete on-prem |
    | DeployProxy | False | Da utilizzare per creare un proxy squid su rete on-prem |

  - Di seguito i parametri utili alla personalizzazione della configurazione di rete della VNet che verrà creata

    | Parametro | Default |
    |:--------- |:------- |
    | HubRgPostfix | Hub |
    | HubVnetPrefix | Hub-VNet |
    | InSubnetPrefix | dns-inbound |
    | OutSubnetPrefix | dns-outbound |
    | PEsubnetName | PE-subnet |
    | HubVnetAddressPrefix  | 10.10.0.0/16 |
    | PEsubnetAddressPrefix  | 10.10.1.0/24 |
    | FirewallSubnetAddressPrefix  | 10.10.2.0/24 |
    | GatewaySubnetAddressPrefix  | 10.10.3.0/24 |
    | BastionSubnetAddressPrefix  | 10.10.0.64/26 |
    | DNSInboundSubnetAddressPrefix  | 10.10.100.0/28 |
    | DNSOutboundSubnetAddressPrefix  | 10.10.100.16/28 |

- Effettuare il login su Azure

```azcli
    az login
```

- Posizionarsi all'interno della sottoscrizione nella quale si vuole creare lo scenario

```azcli
    az account set --subscription <ResourceId della tua sottoscrizione>
```

- Instanziare le 4 variabili sotto

```azcli
    $Seed=(-join ((48..57) + (97..122) | Get-Random -Count 3 | % {[char]$_}))
    $MyIP=<Inserisci il tuo IP>
    $location=<Inserisci la region di riferimento>
    $adminPassword=(-join ((48..59) + (63..91) + (99..123) | Get-Random -count 15 | % {[char]$_})) 
    $MyObecjectId=<Inserisci l'objectId del tuo utente> 
    $SpokesNumber=0
```

- Posizionarsi nella directory dove sono presenti i file Bicep
- Lanciare il comando

```azcli
    az deployment sub create `
      --name "CoreMain-$Seed" `
      --location $location `
      --template-uri "https://raw.githubusercontent.com/gderossilive/CoreInfra/master/ARM/SingolaVNet.json"  `
      --parameters `
            https://raw.githubusercontent.com/gderossilive/CoreInfra/master/Parameters.json `
            Seed=$Seed `
            MyObjectId=$MyObecjectId `
            MyIP=$MyIP `
            adminPassword=$adminPassword
```
