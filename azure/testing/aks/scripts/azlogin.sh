#!/usr/bin/bash
# AZ Login

# <--- Change the following environment variables according to your Azure service principal name --->
AppId='---'
AppSecret='---'
TenantID='---'
ResourceGroup='---'
AKSClusterName='---'
Region='---'

export AppID AppSecret TenantID ResourceGroup AKSClusterName Region

# Getting AKS credentials
echo "Log in to Azure with Service Principal & Getting AKS credentials (kubeconfig)"
az login --service-principal --username $AppId --password $AppSecret --tenant $TenantID

echo "Get Cluster Credentials"
az aks get-credentials --name $AKSClusterName --resource-group $ResourceGroup --file ~/.kube/config --overwrite-existing
