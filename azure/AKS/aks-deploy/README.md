## AKS Cluster Deployment Code

**----  Working  ----**

To install Cilium with Helm charts you can use the Helm provider. Look at aksdeploy-helm.tf for the full code.

#### To Do:

Refactor to use the new integrated cilium CNI

--

#### Example code -

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
