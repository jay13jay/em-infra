output "control_plane_vmid" {
  value = module.control_plane.vmid
}

output "control_plane_ip" {
  value = module.control_plane.ip_address
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
