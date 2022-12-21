#!/bin/sh
# Arc Kubernetes Agent installation

# <--- Change the following environment variables according to your Azure service principal name --->
appId='<Your Azure service principal name>'
password='<Your Azure service principal password>'
tenantId='<Your Azure tenant ID>'
ResourceGroup='<Azure resource group name>'
arcClusterName='<The name of your k8s cluster as it will be shown in Azure Arc>'
region='westus2'

echo "Exporting environment variables"
export appId password tenantId ResourceGroup arcClusterName region

# Installing Azure Arc k8s Extensions
echo "Installing Azure Arc Extensions"
az extension add --name connectedk8s
az extension add --name k8s-configuration

# Getting AKS credentials
echo "Log in to Azure with Service Principal & Getting AKS credentials (kubeconfig)"
az login --service-principal --username $appId --password $password --tenant $tenantId
az aks get-credentials --name $arcClusterName --resource-group $resourceGroup --overwrite-existing

# Connect to Arc
echo "Connecting the cluster to Azure Arc"
az connectedk8s connect --name $arcClusterName --resource-group $ResourceGroup --location $region --tags 'Project=jumpstart_azure_arc_k8s'