### AKS Cluster

Create using local template/module

#### Notes

Install kubectl for PowerShell:  

* [Official Docs - curl/choco/scoop](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
* [PowerShell Module Install-AzAksKubectl](https://docs.microsoft.com/en-us/powershell/module/az.aks/install-azakskubectl?view=azps-8.0.0)

CheatSheets:  

* [kubectl cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/):

Get cluster credentials - may need "az login":

```shell
PS C:\> az aks get-credentials --resource-group <rg_name> --name <cluster_name>
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
  
Access a debug console in a privledged container:

```shell
kubectl debug node/aks-agentpool-34182189-vmss000000 -it --image=mcr.microsoft.com/dotnet/runtime-deps:6.0
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
