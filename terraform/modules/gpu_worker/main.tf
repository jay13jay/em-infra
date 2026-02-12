locals {
  hostpci_assignment = var.x_vga ? "${var.gpu_pci_bdf},pcie=1,x-vga=1" : "${var.gpu_pci_bdf},pcie=1"
}

resource "proxmox_vm_qemu" "this" {
  name        = var.name
  target_node = var.node
  clone       = var.template
  full_clone  = true

  cores  = var.cores
  memory = var.memory_mb

  scsihw  = "virtio-scsi-pci"
  os_type = "cloud-init"

  disk {
    type    = "scsi"
    storage = var.disk_pool
    size    = format("%dG", var.disk_gb)
  }

  network {
    model  = "virtio"
    bridge = var.network_bridge
  }

  ciuser  = var.cloud_init_user
  sshkeys = length(var.ssh_authorized_keys) > 0 ? join("\n", var.ssh_authorized_keys) : null
  ipconfig0 = var.dhcp ? "ip=dhcp" : var.static_ip_config

  agent   = var.enable_qga ? 1 : 0
  ci_wait = var.wait_for_ip_timeout

  # Attach the GPU via PCI passthrough. One GPU per VM only.
  hostpci0 = local.hostpci_assignment
}
