## AKS Cluster-2

Create using local template/module following this example - [Create K8S cluster with tF amd and AKS](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks)

This project currently creates 2 node pools, a "default" pool and a "cpumanager" pool.

ToDo:

* Use the Proximity Placement Group
* Storage Volumes

In this example we are successfuly running post setup commands with the local-exec Provisioner to setup kubectl.config and install the Cillium CNI plugin using Helm.

```terraform
  provisioner "local-exec" {
    # Get the cluster config for kubectl
    command = "az aks get-credentials --resource-group AKS-Testing2 --name TestCluster2"
    on_failure = continue
  }

  provisioner "local-exec" {
    # Add cilium to ther Helm repo
    command = "helm repo add cilium https://helm.cilium.io/"
    on_failure = continue
  }
  
  provisioner "local-exec" {
    # Install cilium as the CNI plugin for network
    command = "helm install cilium cilium/cilium --version 1.12.3  --namespace kube-system  --set aksbyocni.enabled=true  --set nodeinit.enabled=true"
    on_failure = continue
  }
```

---

### Documentation

**Install kubectl for PowerShell:**  

* [Official Docs - curl/choco/scoop](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
* [PowerShell Module Install-AzAksKubectl](https://docs.microsoft.com/en-us/powershell/module/az.aks/install-azakskubectl?view=azps-8.0.0)

**Terraform Azure and AKS Module docs:**

* [Terraform Azure Provider:](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
* [kubernetes_cluster:](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
* [kubernetes_cluster_node_pool:](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool)
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

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* [Terraform AKS Module](https://registry.terraform.io/modules/Azure/aks/azurerm/latest)
