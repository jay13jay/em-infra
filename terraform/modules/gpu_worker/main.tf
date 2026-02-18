locals {
  hostpci_host = var.gpu_pci_bdf
  hostpci_pcie = 1
}

resource "proxmox_vm_qemu" "this" {
  name        = var.name
  target_node = var.node
  clone       = var.template
  full_clone  = true

  cpu {
    cores = var.cores
  }
  memory = var.memory_mb

  scsihw  = "virtio-scsi-pci"
  os_type = "cloud-init"

  disk {
    type    = "disk"
    storage = var.disk_pool
    slot    = "scsi${var.disk_slot}"
    format  = "raw"
    size    = format("%dG", var.disk_gb)
  }

  startup_shutdown {
    order            = -1
    startup_delay    = -1
    shutdown_timeout = -1
  }

  network {
    id     = var.network_id
    model  = "virtio"
    bridge = var.network_bridge
  }

  ciuser  = var.cloud_init_user
  sshkeys = length(var.ssh_authorized_keys) > 0 ? join("\n", var.ssh_authorized_keys) : null
  ipconfig0 = var.dhcp ? "ip=dhcp" : var.static_ip_config

  agent   = var.enable_qga ? 1 : 0
  ci_wait = var.wait_for_ip_timeout

  # Attach the GPU via PCI passthrough. One GPU per VM only.
  hostpci {
    host = local.hostpci_host
    pcie = local.hostpci_pcie
  }
}
