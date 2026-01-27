###===================================================================================###
#  File: main.tf (NVIDIA Blackwell Workstation)
###===================================================================================###

# 1. PERSISTENT SSD (Your "Safety Net")
resource "google_compute_disk" "datadisk01" {
  name  = "${var.vm_name}-data-ssd"
  type  = var.h_disk_type
  size  = var.h_disk_size
  zone  = var.zone
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
    # Inject SSH key from local file
    #ssh-keys = "${var.ssh_user}:${local.ssh_key_content}"
    ssh-keys = "terraform:${file("${local.personal_repo}/secrets/ssh_keys.txt")}"

    # BLACKWELL DE NOVO SETUP SCRIPT
    # This replaces your old cloud-init with the specific NVIDIA stack
    startup-script = <<-EOT
      #!/bin/bash
      set -e
      
      # A. LOGGING
      exec > >(tee /var/log/blackwell-install.log) 2>&1
      echo "Starting Blackwell De Novo Setup..."

      # B. PERSISTENT DISK MOUNT
      DEVICE_PATH="/dev/disk/by-id/google-robotics_data"
      MOUNT_DIR="/mnt/disks/robotics_data"
      mkdir -p $MOUNT_DIR
      if ! blkid $DEVICE_PATH; then
        mkfs.ext4 -m 0 -E discard $DEVICE_PATH
      fi
      mount -o discard,defaults $DEVICE_PATH $MOUNT_DIR
      echo "$DEVICE_PATH $MOUNT_DIR ext4 discard,defaults,nofail 0 2" >> /etc/fstab

      # C. INSTALL NVIDIA DRIVERS (Ubuntu 24.04 / R580-Open)
      # Installing dependencies
      apt-get update
      apt-get install -y linux-headers-$(uname -r) build-essential dkms curl

      # Using Google's managed installer script
      curl -L https://storage.googleapis.com/compute-gpu-installation-us/installer/latest/cuda_installer.pyz --output cuda_installer.pyz
      # Force the 'open' kernel module required for Blackwell
      python3 cuda_installer.pyz install_driver -y --driver-version=580-open
      python3 cuda_installer.pyz install_cuda -y

      # D. INSTALL DOCKER (Moved to Persistent Disk)
      apt-get install -y docker.io
      mkdir -p $MOUNT_DIR/docker
      # Configure Docker to use the 500GB SSD
      echo "{\"data-root\": \"$MOUNT_DIR/docker\"}" > /etc/docker/daemon.json
      systemctl restart docker

      # E. NVIDIA CONTAINER TOOLKIT
      apt-get install -y nvidia-container-toolkit
      nvidia-ctk runtime configure --runtime=docker
      systemctl restart docker
      
      echo "Setup Complete. Rebooting..."
      reboot
    EOT
  }
}