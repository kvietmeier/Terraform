## AKS Cluster-billrun

Create using local template/module following this example - [Create Kubernetes cluster with TerraForm and AKS](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks)

This project currently creates 6 node pools, a "default" pool and pools with Intel, AMD, and Ampere based nodes.

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

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details
