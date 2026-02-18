// Primary resource: clone from an existing cloud-init template
// Notes:
// - This module assumes the provided `template` is a cloud-init–enabled Ubuntu 22.04 template
//   with cloud-init and qemu-guest-agent installed.
// - IP discovery via output depends on QEMU guest agent; if absent the output will be null.

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

  // cloud-init settings (provider maps to the VM's cloud-init drive)
  ciuser    = var.cloud_init_user
  sshkeys   = join("\n", var.ssh_authorized_keys)
  ipconfig0 = var.dhcp ? "ip=dhcp" : var.static_ip_config

  // enable qemu-guest-agent for IP detection and graceful shutdown
  agent   = var.enable_qga ? 1 : 0
  agent_timeout = var.agent_timeout
  ci_wait = var.wait_for_ip_timeout
}
