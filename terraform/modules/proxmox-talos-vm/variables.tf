variable "name" {
  type        = string
  description = "VM name in Proxmox"
}

variable "node" {
  type        = string
  description = "Proxmox node name"
}

variable "template" {
  type        = string
  description = "Talos template name or VMID (e.g., 'talos-v1.12.4-base')"

  validation {
    condition     = length(trimspace(var.template)) > 0
    error_message = "template must be provided (e.g., 'talos-v1.12.4-base')."
  }
}

variable "cores" {
  type        = number
  description = "Number of CPU cores"
  default     = 2
}

variable "memory_mb" {
  type        = number
  description = "Memory in MB"
  default     = 4096
}

variable "disk_gb" {
  type        = number
  description = "Disk size in GB"
  default     = 40
}

variable "disk_pool" {
  type        = string
  description = "Storage pool for VM disk"
  default     = "local-lvm"
}

variable "network_bridge" {
  type        = string
  description = "Network bridge name"
  default     = "vmbr0"
}

variable "gpu_pci_bdf" {
  type        = string
  description = "Optional GPU PCI BDF for passthrough (e.g., '0000:01:00.0')"
  default     = null

  validation {
    condition = (
      var.gpu_pci_bdf == null ||
      can(regex("^[0-9a-fA-F]{4}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\\.[0-9a-fA-F]$", var.gpu_pci_bdf))
    )
    error_message = "gpu_pci_bdf must be in format 0000:00:00.0 (hex digits only) or null."
  }
}

variable "gpu_pcie_mode" {
  type        = bool
  description = "Enable PCIe passthrough mode for GPU"
  default     = true
}

variable "gpu_rombar" {
  type        = bool
  description = "Enable ROM BAR for GPU passthrough"
  default     = true
}

variable "onboot" {
  type        = bool
  description = "Start VM on Proxmox boot"
  default     = true
}
