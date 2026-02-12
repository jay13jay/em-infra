module "gpu_worker" {
  source = "../modules/gpu_worker"

  name                  = "gpu-worker-01"
  node                  = var.node
  template              = var.template
  cores                 = 4
  memory_mb             = 16384
  disk_gb               = 100
  disk_pool             = var.disk_pool
  network_bridge        = var.network_bridge
  ssh_authorized_keys   = var.ssh_authorized_keys
  cloud_init_user       = var.cloud_init_user
  dhcp                  = true
  gpu_pci_bdf           = var.gpu_pci_bdf
  x_vga                 = false
}

output "gpu_worker_vmid" {
  value = module.gpu_worker.vmid
}

output "gpu_worker_ip" {
  value = module.gpu_worker.ip_address
}
