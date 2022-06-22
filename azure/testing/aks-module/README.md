### AKS Cluster

Using the published Hashicorp Terraform AKS module

#### Notes

Get cluster credentials

```text
PS C:\> az aks get-credentials --resource-group aks-resource-group --name cpumgrtesting
```

```text
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

* [https://registry.terraform.io/modules/Azure/aks/azurerm/latest](Terraform AKS Module)
