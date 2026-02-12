output "control_plane_vmid" {
  value = module.control_plane.vmid
}

output "control_plane_vmids" {
  description = "List of control plane VM IDs (single-item list for non-HA)"
  value       = [module.control_plane.vmid]
}

output "control_plane_ip" {
  description = "Control plane IP address (deprecated: use control_plane_ips)"
  value       = module.control_plane.ip_address
}

output "control_plane_ips" {
  description = "List of control plane IPs (single-item list for non-HA)"
  value       = [module.control_plane.ip_address]
}

output "worker_vmids" {
  value = try([for m in module.workers: m.vmid], [])
}

output "worker_ips" {
  value = try([for m in module.workers: m.ip_address], [])
}

output "gpu_worker_vmids" {
  value = try([for m in values(module.gpu_workers): m.vmid], [])
}

output "gpu_worker_ips" {
  value = try([for m in values(module.gpu_workers): m.ip_address], [])
}

output "gpu_worker_bdfs" {
  value = try([for k, m in module.gpu_workers: m.gpu_pci_bdf], [])
}
