// Expose the minimal, useful runtime information
output "vmid" {
  description = "Proxmox VMID assigned to the created VM"
  value       = proxmox_vm_qemu.this.vmid
}

output "vm_name" {
  description = "VM name"
  value       = proxmox_vm_qemu.this.name
}

output "node" {
  description = "Proxmox node where the VM is running"
  value       = var.node
}

output "ip_address" {
  description = "First IPv4 learned from the QEMU guest agent (may be null if guest-agent or DHCP isn't present)"
  value       = try(proxmox_vm_qemu.this.default_ipv4_address, null)
}
