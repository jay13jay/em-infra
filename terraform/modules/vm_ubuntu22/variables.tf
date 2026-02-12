// Reusable Ubuntu 22.04 VM (Proxmox) - inputs
variable "name" {
  description = "Name of the VM"
  type        = string
}

variable "node" {
  description = "Proxmox target node"
  type        = string
}

variable "template" {
  description = "Name or VMID of an existing cloud-init Ubuntu 22.04 template to clone (preferred)"
  type        = string
}

variable "cores" {
  description = "vCPU cores"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "disk_gb" {
  description = "Root disk size in GiB"
  type        = number
  default     = 20
}

variable "disk_pool" {
  description = "Proxmox storage pool for the VM disk"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Network bridge to attach the VM to"
  type        = string
  default     = "vmbr0"
}

variable "ssh_authorized_keys" {
  description = "List of SSH public keys to inject via cloud-init"
  type        = list(string)
  default     = []
}

variable "cloud_init_user" {
  description = "cloud-init user to create/configure"
  type        = string
  default     = "ubuntu"
}

variable "enable_qga" {
  description = "Enable QEMU guest agent (required for IP discovery)"
  type        = bool
  default     = true
}

variable "dhcp" {
  description = "Assume DHCP networking (if false, supply static_ip)"
  type        = bool
  default     = true
}

variable "static_ip_config" {
  description = "Optional ipconfig string when dhcp=false (example: ip=192.168.1.50/24,gw=192.168.1.1)"
  type        = string
  default     = null

  validation {
    condition     = var.dhcp || (var.static_ip_config != null && can(regex("^ip=", var.static_ip_config)))
    error_message = "Provide static_ip_config (ip=.../CIDR[,gw=...]) when dhcp is false."
  }
}

variable "wait_for_ip_timeout" {
  description = "Seconds to wait for guest agent to report an IP"
  type        = number
  default     = 300
}
