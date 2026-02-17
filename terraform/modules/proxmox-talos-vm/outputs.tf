output "vmid" {
  description = "Proxmox VM ID"
  value       = proxmox_vm_qemu.this.id
}

output "vm_name" {
  description = "VM name"
  value       = proxmox_vm_qemu.this.name
}

output "node" {
  description = "Proxmox node hosting this VM"
  value       = proxmox_vm_qemu.this.target_node
}

output "ip_address" {
  description = "First reported IP address (may be null; Talos has no qemu-guest-agent)"
  value       = try(proxmox_vm_qemu.this.default_ipv4_address, null)
}

output "mac_address" {
  description = "MAC address of first network interface"
  value       = try(proxmox_vm_qemu.this.network[0].macaddr, null)
}
