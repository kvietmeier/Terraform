## AKS Cluster-2

Create using local template/module following this example - [Create Kubernetes cluster with TerraForm and AKS](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks)

This project currently creates 3 node pools, a "default" pool and 2 "cpumanager" pools with different VM sizes.

ToDo:

* Use the Proximity Placement Group ***(Done)***
* Storage Volumes ***(Done)***
* Availability Zones
* Enable DPDK

In this example I am running a post setup command with the local-exec Provisioner to setup kubectl.config

```terraform
  provisioner "local-exec" {
    # Get the cluster config for kubectl
    command = "az aks get-credentials --resource-group AKS-Testing2 --name TestCluster2"
    on_failure = continue
  }
```

To install Cilium with Helm charts you can use the Helm provider. Look at aks2-helm.tf for the full code.

```terraform
###----- Helm Charts
resource "helm_release" "cilium_cni" {
  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    ="1.12.3"

  set {
    name  = "aksbyocni.enabled"
    value = "true"
  }
  
  set {
    name  = "nodeinit.enabled"
    value = "true"
  }

  depends_on = [ azurerm_kubernetes_cluster.k8s ]
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