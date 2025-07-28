###===================================================================================###
#  File:        fw.block.public.tf
#  Author:      Karl Vietmeier
#
#  Purpose:     Define a firewall rule to block common administrative and
#               diagnostic protocols (ICMP, SSH, RDP, SMB) from the public
#               internet for the ‘karlv-corevpc’ VPC on GCP.
#
#  Contents:
#    - deny_public_ingress   → Blocks ICMP, TCP/22, TCP/3389, TCP/445, UDP/445
#
#  Related Files:
#    - fw.main.tf            → Main firewall rule definitions
#    - fw.terraform.tfvars   → Variable values for project, tags, CIDRs, etc.
###===================================================================================###

###--- Create the FW Rule to Deny ICMP, SSH, RDP, and SMB from the Public Internet
resource "google_compute_firewall" "deny_public_ingress" {
  name        = "deny-public-ingress"
  network     = var.vpc_name
  description = "Deny incoming ICMP, SSH, RDP, and SMB traffic from public IPs"
  direction   = "INGRESS"
  priority    = 1000

  # Block ICMP
  deny {
    protocol = "icmp"
  }

  # Block SSH (22), RDP (3389), SMB (445) over TCP
  deny {
    protocol = "tcp"
    ports    = ["22", "3389", "445"]
  }

  # Block SMB over UDP
  deny {
    protocol = "udp"
    ports    = ["445"]
  }

  # Anything not explictly on the ingress list
  source_ranges = ["0.0.0.0/0"]

  # Optional: restrict to specific target tags
  # target_tags = ["no-public-access"]

  disabled = false
}
