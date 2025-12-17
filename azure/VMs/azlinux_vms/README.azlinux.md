## Azure Linux (HPC) Terraform Deployment

### Overview

This project deploys High-Performance Computing (HPC) Virtual Machines on Azure using **Terraform**. It is specifically configured for **Azure Linux (CBL-Mariner)**, Microsoft's internal Linux distribution optimized for Azure infrastructure.

### Key Features

* **OS:** Azure Linux (HPC Image) via Azure Marketplace.
* **Hardware:** NVMe-enabled VMs (`Standard_E2bds_v5`) with UltraSSD data disks.
* **Performance:** Kernel locking to prevent updates from breaking drivers; Time sync via Azure Hyper-V host.
* **Tools:** Automated compilation of FIO, iPerf, Dool, SockPerf, and Elbencho via Cloud-Init.

---

## Important Notes on Azure Linux

* **Package Manager:** Uses `tdnf` (Tiny DNF), aliased to `dnf`. It is RPM-based (similar to RHEL/CentOS).
* **Kernel Locking:** This deployment automatically adds `exclude=kernel*` to `/etc/dnf/dnf.conf` to prevent accidental kernel upgrades during patch cycles.
* **NVMe Support:** The Terraform code enables `disk_controller_type = "NVMe"`, which is required for Gen2 VMs to access local NVMe storage efficiently.

---

## Prerequisites to use Azure Linux HPC Images

#### 1. Find the Images

```shell
# Replace variables with your target (e.g., location westus3)
az vm image list `
   --location $region `
   --publisher azure-hpc `
   --offer azurelinux-hpc `
   --sku 3 `
   --all `
   -o table
```

**Example - westus3**

```shell
Architecture  Offer           Publisher   Sku            Urn                                                 Version
------------  --------------  ----------  -------------  --------------------------------------------------  --------------
x64           azurelinux-hpc  azure-hpc   3              azure-hpc:azurelinux-hpc:3:3.0.2025092901           3.0.2025092901
x64           azurelinux-hpc  azure-hpc   3-fips         azure-hpc:azurelinux-hpc:3-fips:3.0.2025092901      3.0.2025092901
x64           azurelinux-hpc  azure-hpc   3-mi300x       azure-hpc:azurelinux-hpc:3-mi300x:3.0.2025120801    3.0.2025120801
x64           azurelinux-hpc  azure-hpc   3-v100         azure-hpc:azurelinux-hpc:3-v100:3.0.2025092901      3.0.2025092901
```

#### 2. Accept Legal Terms (One-Time)

Before deploying this specific Marketplace image programmatically, you must accept the license agreement for your subscription.

```powershell
az vm image terms accept --urn "azure-hpc:azurelinux-hpc:3:latest"
```

---

#### Author

* **Karl Vietmeier**

#### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
