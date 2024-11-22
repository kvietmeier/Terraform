### Terraform for GCP Projects

Terraform templates for creating infrastructure in Azure.

#### Documentation Links

- [Terraform on GCP](https://cloud.google.com/docs/terraform)
- [HashiLearn - GCP](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started)
- [Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Google Module Registry](https://registry.terraform.io/providers/hashicorp/google/latest)

---

#### Misc Notes

---

#### GCP Quirks

- Linux images provided on GCP do not have cloud-init installed!
  You will need to use the metadata block in the VM resource to run a startup scrupt to install it
  
  This code runs a small script to install cloud-init and reboot then adds SSH keys to authorized_keys, enables serial port access and then adds the cloud-init.yml to configure the system.

  ```terraform
  metadata = {
    # Install cloud-init if not available yet
    startup-script = <<-EOT
    #!/bin/bash
    command -v cloud-init &>/dev/null || (dnf install -y cloud-init && reboot)
    EOT
    
    ssh-keys           = "${var.ssh_user}:${local.ssh_key_content}"
    serial-port-enable = true # Enable serial port access for debugging
    user-data          = "${data.cloudinit_config.system_setup.rendered}"
  }
  ```

---

#### My code is Built With

- [Visual Studio Code](https://code.visualstudio.com/) - Editor
- [Terraform](https://www.terraform.io/) - Terraform

#### All run under PowerShell on Windows 10/11

- [Use Windows Terminal Console](https://docs.microsoft.com/en-us/windows/terminal/)

#### Author/s

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](../LICENSE.md) file for details

#### Acknowledgments

- ChatGPT which feels kind of like cheating
