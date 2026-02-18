// Module: proxmox-talos-vm
// Purpose: Clone Talos template and provision a Talos node (no cloud-init, no guest agent assumptions)
// Architecture: docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md

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
  os_type = "l26"  // Generic Linux for Talos (not cloud-init)

  disk {
    type    = "disk"
    storage = var.disk_pool
    slot    = "scsi0"
    format  = "raw"
    size    = "${var.disk_gb}G"
  }

  startup_shutdown {
    order            = -1
    startup_delay    = -1
    shutdown_timeout = -1
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.network_bridge
  }

  // Talos does not support qemu-guest-agent
  agent = 0

  // No cloud-init for Talos nodes
  // Machine config will be injected via separate mechanism (configdrive ISO or network-based config URL)

  // Optional: GPU passthrough
  dynamic "hostpci" {
    for_each = var.gpu_pci_bdf != null ? [var.gpu_pci_bdf] : []
    content {
      host    = hostpci.value
      pcie    = var.gpu_pcie_mode
      rombar  = var.gpu_rombar
    }
  }

  // Boot immediately after clone
  boot = "order=scsi0"
  start_at_node_boot = var.onboot

  // Note: Talos manages its own network state via machine config
  // If network drift is detected, it likely indicates a machine config change
  // applied outside of Terraform, which is expected in the Talos workflow

  lifecycle {
    ignore_changes = [agent, reboot_required]
  }
}
