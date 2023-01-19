## Setting up AKS Clusters

Initially following this example - [Create K8S cluster with TF and AKS](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks)

Project folder for developing Terraform code to create AKS clusters

Goals:  

* Test applying kubelet, linux OS, and sysctl custom settings to nodepools.
* Use Terraform for deployments

---

### Source Documentation for Reference -

**Install kubectl for PowerShell:**  

* [Official Docs - curl/choco/scoop](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
* [PowerShell Module Install-AzAksKubectl](https://docs.microsoft.com/en-us/powershell/module/az.aks/install-azakskubectl?view=azps-8.0.0)

**Terraform Azure and AKS Module docs:**

* [Terraform Azure Provider:](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
* [Terraform Kubernetes Provider:](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
* [AzureRM - kubernetes_cluster:](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
* [AzureRM - kubernetes_cluster_node_pool:](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool)
* [Helm](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)

**CheatSheets:**  

* [kubectl cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/):

---

### Notes

Get cluster credentials - may need "az login":

```shell
az aks get-credentials --resource-group <rg_name> --name <cluster_name>
```

Basic cluster information:

```shell
kubectl cluster-info
```
  
Dump detailed cluster information:

```shell
kubectl cluster-info dump
```
  
Show me the nodes:

```shell
kubectl get nodes
NAME                                STATUS   ROLES   AGE   VERSION
aks-agentpool-34182189-vmss000000   Ready    agent   11h   v1.23.12
aks-agentpool-34182189-vmss000001   Ready    agent   11h   v1.23.12
```
  
List Namespaces:

```shell
kubectl get namespace
NAME                   STATUS   AGE
default                Active   11h
kube-node-lease        Active   11h
kube-public            Active   11h
kube-system            Active   11h
```
  
Get all deployments in all namespaces:

```shell
kubectl get deployments --all-namespaces=true
NAMESPACE              NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
kube-system            coredns                     2/2     2            2           11h
kube-system            coredns-autoscaler          1/1     1            1           11h
kube-system            konnectivity-agent          2/2     2            2           11h
kube-system            metrics-server              2/2     2            2           11h
kube-system            omsagent-rs                 1/1     1            1           11h
kubernetes-dashboard   dashboard-metrics-scraper   1/1     1            1           10h
```
  
Access a debug console in a privledged container - replace agentpool with current value:

```shell
kubectl debug node/aks-agentpool-27684724-vmss000000 -it --image=mcr.microsoft.com/dotnet/runtime-deps:6.0
```

```shell
Creating debugging pod node-debugger-aks-agentpool-34182189-vmss000000-pkhvf with container debugger on node aks-agentpool-34182189-vmss000000.
If you don't see a command prompt, try pressing enter.
root@aks-agentpool-34182189-vmss000000:/#
  
```

Bash script to authenticate to Azure and setup cluster access

```bash
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

echo ""
```

---

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

TBD  
