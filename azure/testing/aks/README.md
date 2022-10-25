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
PS C:\> kubectl get namespace
NAME                STATUS   AGE
default             Active   20h
gatekeeper-system   Active   20h
kube-node-lease     Active   20h
kube-public         Active   20h
kube-system         Active   20h
```

Get all deplopymenmts in all namespaces

```shell
kubectl get deployments --all-namespaces=true
```

Access a debug console in a privledged container -

```shell
kubectl debug node/<node_name> -it --image=mcr.microsoft.com/dotnet/runtime-deps:6.0

```







#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* [Terraform AKS Module](https://registry.terraform.io/modules/Azure/aks/azurerm/latest)
