


# Misc
variable "prefix" { type = string }
variable "suffix" { type = string }


###===================================================================================###
#   NSG Configuration Parameters
###===================================================================================###

variable region_map {
  type = map
}

# Allow list for NSG
variable whitelist_ips {
  description = "A list of IP CIDR ranges to allow as clients. Do not use Azure tags like `Internet`."
  type        = list(string)
}

# Destination Port list
variable destination_ports {
  description = "A list of standard network services: SSH, FTP, RDP, SMP, etc."
  type        = list(string)
}
