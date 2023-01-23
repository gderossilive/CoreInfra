# Introduzione
Studiare e mantenersi aggiornato è una delle attività più importanti che un Cloud Solution Architect deve svolgere. Questo implica dover sperimentare e testare nuove funzionalità e nuovi rilasci che vengono fatti continuamente dai nostri colleghi dei diversi Product Group di Azure.
Disporre di un ambiente di test su Azure diventa perciò necessario per svolgere questo compito. A questo punto si presentano due alternative:

- Mantenere un ambiente di test sempre acceso
- Crearlo e distruggerlo all'occorrenza

In questo repository pubblicheremo uno script Bicep per realizzare la seconda opzione e coprire diversi scenari.

# Architettura
L'ambiente realizzato tramite questo script è articolato in 2 parti principali:

- Una parte che rappresenta una tipica architettura Hub&Spoke
- Una parte che può essere utilizzata per rappresentare una VLan OnPrem collegata con l'Hub

## Architettura Hub&Spoke


Prova a farne il deploy sulla tua sottoscrizione

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgderossilive%2FCoreInfra%2Fmaster%2FARM%2Fazuredeploy.json)