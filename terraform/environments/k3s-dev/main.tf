locals {
  name_prefix = var.env_name
}

module "control_plane" {
  source = "../../modules/vm_ubuntu22"

  name                  = "${local.name_prefix}-control-1"
  node                  = var.node
  template              = var.control_plane_template
  cores                 = var.control_plane_cores
  memory_mb             = var.control_plane_memory_mb
  disk_gb               = var.control_plane_disk_gb
  disk_pool             = var.disk_pool
  network_bridge        = var.network_bridge
  ssh_authorized_keys   = var.ssh_authorized_keys
  cloud_init_user       = "ubuntu"
  dhcp                  = var.dhcp
  static_ip_config      = lookup(var.static_ip_map, "${local.name_prefix}-control-1", null)
  wait_for_ip_timeout   = var.wait_for_ip_timeout
}

module "workers" {
  count = var.worker_count
  source = "../../modules/vm_ubuntu22"

  name                = "${local.name_prefix}-worker-${count.index + 1}"
  node                = var.node
  template            = var.worker_template
  cores               = var.worker_cores
  memory_mb           = var.worker_memory_mb
  disk_gb             = var.worker_disk_gb
  disk_pool           = var.disk_pool
  network_bridge      = var.network_bridge
  ssh_authorized_keys = var.ssh_authorized_keys
  cloud_init_user     = "ubuntu"
  dhcp                = var.dhcp
  static_ip_config    = lookup(var.static_ip_map, "${local.name_prefix}-worker-${count.index + 1}", null)
  wait_for_ip_timeout = var.wait_for_ip_timeout
}

module "gpu_workers" {
  source  = "../../modules/gpu_worker"
  for_each = toset(var.gpu_worker_pci_bdfs)

  name                = "${local.name_prefix}-gpu-${replace(each.value, ":", "-") }"
  node                = var.node
  template            = var.gpu_worker_template
  cores               = var.gpu_worker_cores
  memory_mb           = var.gpu_worker_memory_mb
  disk_gb             = var.gpu_worker_disk_gb
  disk_pool           = var.disk_pool
  network_bridge      = var.network_bridge
  ssh_authorized_keys = var.ssh_authorized_keys
  cloud_init_user     = "ubuntu"
  dhcp                = var.dhcp
  static_ip_config    = lookup(var.static_ip_map, "${local.name_prefix}-gpu-${replace(each.value, ":", "-")}", null)
  wait_for_ip_timeout = var.wait_for_ip_timeout

  gpu_pci_bdf         = each.value
}
