output "vmid" {
  description = "VMID of the created VM"
  value       = proxmox_vm_qemu.this.vmid
}

output "vm_name" {
  description = "Name of the VM"
  value       = proxmox_vm_qemu.this.name
}

output "node" {
  description = "Proxmox node the VM is on"
  value       = var.node
}

output "ip_address" {
  description = "Discovered IPv4 address (if guest agent provides it)"
  value       = try(proxmox_vm_qemu.this.default_ipv4_address, null)
}

output "gpu_pci_bdf" {
  description = "The GPU PCI BDF passed into the module"
  value       = var.gpu_pci_bdf
}

output "hostpci_assignment" {
  description = "The final hostpci assignment string used on the VM"
  value       = local.hostpci_assignment
}
