# Moved → CoreInfra

The GCP BIND mini-forwarder lives under CoreInfra with the other infra VMs:

**[`gcp/CoreInfra/vms/bind_forwarder/`](../../CoreInfra/vms/bind_forwarder/)**

```bash
cd gcp/CoreInfra/vms/bind_forwarder
cp bind.auto.tfvars.example bind.auto.tfvars
terraform init && terraform apply
```

Shared cloud-init unchanged: [`scripts/cloud-init/cloud-init-bind.yaml.tftpl`](../../../scripts/cloud-init/cloud-init-bind.yaml.tftpl).
