### AKS Cluster

Using the published Hashicorp Terraform AKS module

#### Notes

Install kubectl for PowerShell:  
* [Official Docs - curl/choco/scoop](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
* [PowerShell Module Install-AzAksKubectl](https://docs.microsoft.com/en-us/powershell/module/az.aks/install-azakskubectl?view=azps-8.0.0)

CheatSheets:  
* [kubectl cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/):

Get cluster credentials:

```shell
PS C:\> az aks get-credentials --resource-group aks-resource-group --name cpumgrtesting
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






#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* [Terraform AKS Module](https://registry.terraform.io/modules/Azure/aks/azurerm/latest)
