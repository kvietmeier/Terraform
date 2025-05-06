### Create VMs
---

#### GCP Quirks

- Many Linux images provided on GCP do not have cloud-init installed!
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
    user-data          = "${data.cloudinit_config.system_setup.rendered}"
    serial-port-enable = true
  }
  ```

- Adding more than one SSH Key to a Linux host
  By default you can only add one but Terraform and GCP allow you to reference a file with multiple keys in it.

  You need to reference it in 3 places:

  "metadata" - see user-data the line in the code above
  As a variable in variables and tfvars

---

#### Author/s

- **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](../LICENSE.md) file for details

#### Acknowledgments

- ChatGPT which feels kind of like cheating
