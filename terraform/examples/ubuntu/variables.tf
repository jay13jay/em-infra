variable "node" {
  description = "Target Proxmox node"
  type        = string
}

variable "template" {
  description = "Existing Ubuntu 22.04 cloud-init template name or VMID"
  type        = string
}

variable "disk_pool" {
  description = "Storage pool for the VM disk"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Network bridge to attach to"
  type        = string
  default     = "vmbr0"
}

variable "ssh_authorized_keys" {
  description = "List of SSH public keys to inject via cloud-init"
  type        = list(string)
}
