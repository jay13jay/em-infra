variable "name" {
  description = "Name of the VM"
  type        = string
}

variable "node" {
  description = "Proxmox node to target"
  type        = string
}

variable "template" {
  description = "Cloud-init template to clone (Proxmox VM ID or name)"
  type        = string
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 4096
}

variable "disk_gb" {
  description = "Root disk size in GB"
  type        = number
  default     = 40
}

variable "disk_pool" {
  description = "Storage pool for the disk"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Bridge to attach VM to"
  type        = string
  default     = "vmbr0"
}

variable "ssh_authorized_keys" {
  description = "List of SSH public keys to inject"
  type        = list(string)
  default     = []
}

variable "cloud_init_user" {
  description = "cloud-init username"
  type        = string
  default     = "ubuntu"
}

variable "enable_qga" {
  description = "Enable QEMU guest agent"
  type        = bool
  default     = true
}

variable "dhcp" {
  description = "If true, use DHCP for IP assignment"
  type        = bool
  default     = true
}

variable "static_ip_config" {
  description = "Static ipconfig string for cloud-init (used when dhcp = false)"
  type        = string
  default     = ""
}

variable "wait_for_ip_timeout" {
  description = "Cloud-init wait timeout (secs)"
  type        = number
  default     = 120
}

variable "gpu_pci_bdf" {
  description = "PCI BDF for the GPU to passthrough (required). Format: 0000:03:00.0"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{4}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\\.[0-7]$", var.gpu_pci_bdf))
    error_message = "gpu_pci_bdf must be a PCI BDF like 0000:03:00.0"
  }
}

variable "x_vga" {
  description = "Set x-vga flag on hostpci assignment. Default false; enable only if needed for the GPU/guest." 
  type        = bool
  default     = false
}

variable "host_bind_helper" {
  description = "If true, the helper bind script will be placed in module files for operator use (not executed)."
  type        = bool
  default     = true
}
