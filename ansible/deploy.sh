#!/bin/bash
echo "--> Ejecución del playbook podman y creación de imagenes <--"
ansible-playbook -i inventary playbook.yaml
echo "--> Credenciales del AKS <--"
az aks get-credentials --resource-group rg-casopractico2TF --name aks-aksjrng76
echo "--> Ejecución del playbookaks <--"
ansible-playbook playbookaks.yaml