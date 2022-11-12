#!/bin/sh
# Arc Agent installation

# <--- Change the following environment variables according to your Azure service principal name --->
appId='<Your Azure service principal name>'
password='<Your Azure service principal password>'
tenantID='<Your Azure tenant ID>'
resourceGroup='<Azure resource group name>'
arcClusterName='<The name of your k8s cluster as it will be shown in Azure Arc>'
region='westus2'

export appId password tenantID resourceGroup arcClusterName region


# Getting AKS credentials
echo "Log in to Azure with Service Principal & Getting AKS credentials (kubeconfig)"
az login --service-principal --username $appId --password $password --tenant $tenantID
az aks get-credentials --name $arcClusterName --resource-group $resourceGroup --overwrite-existing

# Installing Azure Arc k8s Extensions
echo "Installing Azure Arc Extensions"
az extension add --name connectedk8s
az extension add --name k8s-configuration

echo "Connecting the cluster to Azure Arc"
az connectedk8s connect --name $arcClusterName --resource-group $resourceGroup --location $region --tags 'Project=Azure_Arc_K8s'
