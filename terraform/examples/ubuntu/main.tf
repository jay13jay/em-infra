// Example: clone from an existing cloud-init Ubuntu 22.04 template
provider "proxmox" {}

module "example_vm" {
  source = "../../modules/vm_ubuntu22"

  name                = "example-control-plane-01"
  node                = var.node
  template            = var.template
  cores               = 2
  memory_mb           = 4096
  disk_gb             = 40
  disk_pool           = var.disk_pool
  network_bridge      = var.network_bridge
  ssh_authorized_keys = var.ssh_authorized_keys
}

output "vmid" {
  value = module.example_vm.vmid
}

output "ip" {
  value = module.example_vm.ip_address
}
