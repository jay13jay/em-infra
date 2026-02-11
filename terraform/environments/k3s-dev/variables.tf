variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API URL"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API token id"
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "Proxmox API token secret"
  sensitive   = true
}

variable "proxmox_user" {
  type        = string
  description = "Proxmox user (optional)"
  default     = null
}

variable "env_name" {
  type        = string
  description = "Short environment name used as VM name prefix"
  default     = "k3s-dev"
}

variable "node" {
  type        = string
  description = "Proxmox target node for VMs"
}

variable "control_plane_template" {
  type        = string
  description = "Template name or VMID to use for control plane VM"
}

variable "control_plane_cores" {
  type    = number
  default = 2
}

variable "control_plane_memory_mb" {
  type    = number
  default = 2048
}

variable "control_plane_disk_gb" {
  type    = number
  default = 20
}

variable "worker_count" {
  type    = number
  description = "Number of non-GPU worker VMs to create"
  default = 0
}

variable "worker_template" {
  type        = string
  description = "Template for non-GPU workers"
  default     = ""
}

variable "worker_cores" {
  type    = number
  default = 2
}

variable "worker_memory_mb" {
  type    = number
  default = 2048
}

variable "worker_disk_gb" {
  type    = number
  default = 20
}

variable "gpu_worker_pci_bdfs" {
  type        = list(string)
  description = "List of GPU PCI BDFs (one GPU worker per BDF). Example: [\"0000:03:00.0\"]"
  default     = []
}

variable "gpu_worker_template" {
  type    = string
  default = ""
}

variable "gpu_worker_cores" {
  type    = number
  default = 2
}

variable "gpu_worker_memory_mb" {
  type    = number
  default = 4096
}

variable "gpu_worker_disk_gb" {
  type    = number
  default = 40
}

variable "ssh_authorized_keys" {
  type    = list(string)
  default = []
}

variable "disk_pool" {
  type    = string
  default = "local-lvm"
}

variable "network_bridge" {
  type    = string
  default = "vmbr0"
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
}
