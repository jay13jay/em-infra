variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API URL"

  validation {
    condition     = can(regex("^https?://", var.proxmox_api_url)) && can(regex("/api2/json/?$", var.proxmox_api_url))
    error_message = "proxmox_api_url must be an http(s) URL ending with /api2/json (example: https://proxmox.example:8006/api2/json)."
  }
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API token id"
  sensitive   = true

  validation {
    condition     = length(trimspace(var.proxmox_api_token_id)) > 0
    error_message = "proxmox_api_token_id is required and cannot be empty."
  }
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "Proxmox API token secret"
  sensitive   = true

  validation {
    condition     = length(trimspace(var.proxmox_api_token_secret)) > 0
    error_message = "proxmox_api_token_secret is required and cannot be empty."
  }
}

variable "proxmox_user" {
  type        = string
  description = "Proxmox user (optional)"
  default     = null
}

variable "proxmox_password" {
  type        = string
  description = "Proxmox PAM password for pm_user (optional; prefer API tokens)"
  default     = null
  sensitive   = true
}

variable "env_name" {
  type        = string
  description = "Short environment name used as VM name prefix"
  default     = "k3s-dev"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.env_name))
    error_message = "env_name must use lowercase letters, numbers, and hyphens only (example: k3s-dev)."
  }
}

variable "node" {
  type        = string
  description = "Proxmox target node for VMs"

  validation {
    condition     = length(trimspace(var.node)) > 0
    error_message = "node is required and cannot be empty."
  }
}

variable "control_plane_template" {
  type        = string
  description = "Template name or VMID to use for control plane VM"

  validation {
    condition     = length(trimspace(var.control_plane_template)) > 0
    error_message = "control_plane_template is required and cannot be empty."
  }
}

variable "control_plane_cores" {
  type    = number
  default = 2

  validation {
    condition     = var.control_plane_cores >= 1
    error_message = "control_plane_cores must be >= 1."
  }
}

variable "control_plane_memory_mb" {
  type    = number
  default = 2048

  validation {
    condition     = var.control_plane_memory_mb >= 1024
    error_message = "control_plane_memory_mb must be >= 1024."
  }
}

variable "control_plane_disk_gb" {
  type    = number
  default = 20

  validation {
    condition     = var.control_plane_disk_gb >= 10
    error_message = "control_plane_disk_gb must be >= 10."
  }
}

variable "worker_count" {
  type    = number
  description = "Number of non-GPU worker VMs to create"
  default = 0

  validation {
    condition     = var.worker_count >= 0
    error_message = "worker_count must be >= 0."
  }
}

variable "worker_template" {
  type        = string
  description = "Template for non-GPU workers"
  default     = ""

  validation {
    condition     = var.worker_template == "" || length(trimspace(var.worker_template)) > 0
    error_message = "worker_template must be empty or a non-empty template name/VMID."
  }
}

variable "worker_cores" {
  type    = number
  default = 2

  validation {
    condition     = var.worker_cores >= 1
    error_message = "worker_cores must be >= 1."
  }
}

variable "worker_memory_mb" {
  type    = number
  default = 2048

  validation {
    condition     = var.worker_memory_mb >= 1024
    error_message = "worker_memory_mb must be >= 1024."
  }
}

variable "worker_disk_gb" {
  type    = number
  default = 20

  validation {
    condition     = var.worker_disk_gb >= 10
    error_message = "worker_disk_gb must be >= 10."
  }
}

variable "gpu_worker_pci_bdfs" {
  type        = list(string)
  description = "List of GPU PCI BDFs (one GPU worker per BDF). Example: [\"0000:03:00.0\"]"
  default     = []

  validation {
    condition     = alltrue([for bdf in var.gpu_worker_pci_bdfs : can(regex("^[0-9a-fA-F]{4}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\\.[0-7]$", bdf))])
    error_message = "Each gpu_worker_pci_bdfs entry must be a PCI BDF like 0000:03:00.0."
  }
}

variable "gpu_worker_template" {
  type    = string
  default = ""

  validation {
    condition     = var.gpu_worker_template == "" || length(trimspace(var.gpu_worker_template)) > 0
    error_message = "gpu_worker_template must be empty or a non-empty template name/VMID."
  }
}

variable "gpu_worker_cores" {
  type    = number
  default = 2

  validation {
    condition     = var.gpu_worker_cores >= 1
    error_message = "gpu_worker_cores must be >= 1."
  }
}

variable "gpu_worker_memory_mb" {
  type    = number
  default = 4096

  validation {
    condition     = var.gpu_worker_memory_mb >= 1024
    error_message = "gpu_worker_memory_mb must be >= 1024."
  }
}

variable "gpu_worker_disk_gb" {
  type    = number
  default = 40

  validation {
    condition     = var.gpu_worker_disk_gb >= 10
    error_message = "gpu_worker_disk_gb must be >= 10."
  }
}

variable "ssh_authorized_keys" {
  type        = list(string)
  default     = []
  description = "List of SSH public keys to inject into all VMs. Operator must ensure matching private key is available."
}

variable "ssh_public_key_comment" {
  type        = string
  default     = ""
  description = "Optional comment to document which private key matches ssh_authorized_keys (e.g., 'Matches ~/.ssh/id_rsa')"
}

variable "cluster_cidr" {
  type        = string
  default     = "10.42.0.0/16"
  description = "Kubernetes pod network CIDR (k3s default: 10.42.0.0/16). Used for validation and documentation."

  validation {
    condition     = can(cidrnetmask(var.cluster_cidr))
    error_message = "cluster_cidr must be a valid CIDR (example: 10.42.0.0/16)."
  }
}

variable "service_cidr" {
  type        = string
  default     = "10.43.0.0/16"
  description = "Kubernetes service network CIDR (k3s default: 10.43.0.0/16). Used for validation and documentation."

  validation {
    condition     = can(cidrnetmask(var.service_cidr))
    error_message = "service_cidr must be a valid CIDR (example: 10.43.0.0/16)."
  }
}

variable "cluster_network_cidr" {
  type        = string
  default     = ""
  description = "Optional: canonical cluster node network CIDR (e.g., '192.168.1.0/24'). Used for static IP validation. Leave empty if using DHCP."

  validation {
    condition     = var.cluster_network_cidr == "" || can(cidrnetmask(var.cluster_network_cidr))
    error_message = "cluster_network_cidr must be empty or a valid CIDR (example: 192.168.1.0/24)."
  }
}

variable "disk_pool" {
  type    = string
  default = "local-lvm"

  validation {
    condition     = length(trimspace(var.disk_pool)) > 0
    error_message = "disk_pool must be a non-empty Proxmox storage identifier."
  }
}

variable "network_bridge" {
  type    = string
  default = "vmbr0"

  validation {
    condition     = length(trimspace(var.network_bridge)) > 0
    error_message = "network_bridge must be a non-empty Proxmox bridge name."
  }
}

variable "dhcp" {
  type    = bool
  default = true
}

variable "static_ip_map" {
  type    = map(string)
  default = {}
  description = "Optional map of VM name -> cloud-init ipconfig string (e.g. \"ip=192.168.1.10/24,gw=192.168.1.1\")"
}

variable "wait_for_ip_timeout" {
  type    = number
  default = 300

  validation {
    condition     = var.wait_for_ip_timeout >= 30 && var.wait_for_ip_timeout <= 3600
    error_message = "wait_for_ip_timeout must be between 30 and 3600 seconds."
  }
}
