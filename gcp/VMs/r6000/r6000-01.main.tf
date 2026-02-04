###===================================================================================###
#  File:        main.tf
#  Created By:  Karl Vietmeier
#  Purpose:     De Novo NVIDIA Blackwell Workstation Deployment (Ubuntu 24.04)
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
###===================================================================================###


# 1. PERSISTENT DATA DISK (Hyperdisk Balanced)
resource "google_compute_disk" "datadisk01" {
  name = "${var.vm_name}-data-ssd"
  type = var.h_disk_type  # Defaults to "hyperdisk-balanced" in your variables
  size = var.h_disk_size
  zone = var.zone
}

# 2. BLACKWELL WORKSTATION INSTANCE
resource "google_compute_instance" "r6000_workstation" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = var.vm_tags

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = var.bootdisk_size
      
      # -----------------------------------------------------------
      # CRITICAL FIX: Explicitly set Boot Disk to Hyperdisk
      # The G4 machine type REJECTS pd-standard/pd-ssd
      # -----------------------------------------------------------
      type = "hyperdisk-balanced" 
    }
  }

  attached_disk {
    source      = google_compute_disk.datadisk01.id
    device_name = "robotics_data"
  }

  guest_accelerator {
    # 'vws' variant required for remote streaming
    type  = "nvidia-rtx-pro-6000-vws"
    count = 2
  }

  scheduling {
    on_host_maintenance = "TERMINATE"
    automatic_restart   = true
  }

  service_account {
    email  = var.sa_email
    scopes = var.sa_scopes
  }

  network_interface {
    network    = var.vpc_name
    subnetwork = var.subnet_name
    access_config {} # Public IP for WebRTC Streaming
  }

  metadata = {
    # Uses the local logic from your variables file
    ssh-keys = "terraform:${local.ssh_key_content}"

    # REVISED STARTUP SCRIPT (Ubuntu 24.04 + Blackwell + APT)
    startup-script = <<-EOT
      #!/bin/bash
      set -e
      
      # Log output for debugging
      exec > >(tee /var/log/blackwell-install.log) 2>&1
      echo "--- Starting Robust Driver Setup ---"

      # 1. MOUNT PERSISTENT DISK
      DEVICE_PATH="/dev/disk/by-id/google-robotics_data"
      MOUNT_DIR="/mnt/disks/robotics_data"
      mkdir -p $MOUNT_DIR
      
      if ! blkid $DEVICE_PATH; then
        mkfs.ext4 -m 0 -E discard $DEVICE_PATH
      fi
      mount -o discard,defaults $DEVICE_PATH $MOUNT_DIR
      
      if ! grep -qs "$MOUNT_DIR" /etc/fstab; then
        echo "$DEVICE_PATH $MOUNT_DIR ext4 discard,defaults,nofail 0 2" >> /etc/fstab
      fi

      # 2. ADD NVIDIA REPO (Forcing Ubuntu 24.04 packages)
      apt-get update
      apt-get install -y wget software-properties-common
      wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
      dpkg -i cuda-keyring_1.1-1_all.deb
      apt-get update

      # 3. INSTALL DRIVERS (580-open for Blackwell Support)
      apt-get install -y linux-headers-$(uname -r) build-essential
      apt-get install -y nvidia-driver-580-open cuda-toolkit-12-8

      # 4. INSTALL DOCKER (Redirected to Persistent SSD)
      apt-get install -y docker.io
      mkdir -p $MOUNT_DIR/docker
      
      cat <<EOF > /etc/docker/daemon.json
      {
          "data-root": "$MOUNT_DIR/docker",
          "runtimes": {
              "nvidia": {
                  "path": "nvidia-container-runtime",
                  "runtimeArgs": []
              }
          }
      }
      EOF

      # 5. NVIDIA CONTAINER TOOLKIT
      apt-get install -y nvidia-container-toolkit
      nvidia-ctk runtime configure --runtime=docker
      systemctl restart docker

      echo "--- Setup Complete. Rebooting. ---"
      reboot
    EOT
  }
}