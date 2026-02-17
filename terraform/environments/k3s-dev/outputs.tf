locals {
  control_plane_name = "${var.env_name}-control-1"
  worker_names       = [for index in range(var.worker_count) : "${var.env_name}-worker-${index + 1}"]
  gpu_worker_bdfs    = sort(keys(module.gpu_workers))

  control_plane_node = {
    role = "control_plane"
    name = local.control_plane_name
    vmid = module.control_plane.vmid
    ip   = module.control_plane.ip_address
    node = var.node
  }

  worker_nodes = [
    for index, instance in module.workers : {
      role = "worker"
      name = local.worker_names[index]
      vmid = instance.vmid
      ip   = instance.ip_address
      node = var.node
    }
  ]

  gpu_worker_nodes = [
    for bdf in local.gpu_worker_bdfs : {
      role        = "gpu_worker"
      name        = module.gpu_workers[bdf].vm_name
      vmid        = module.gpu_workers[bdf].vmid
      ip          = module.gpu_workers[bdf].ip_address
      node        = var.node
      gpu_pci_bdf = module.gpu_workers[bdf].gpu_pci_bdf
    }
  ]

  node_ip_map = merge(
    { (local.control_plane_node.name) = local.control_plane_node.ip },
    { for worker in local.worker_nodes : worker.name => worker.ip },
    { for worker in local.gpu_worker_nodes : worker.name => worker.ip }
  )

  node_vmid_map = merge(
    { (local.control_plane_node.name) = local.control_plane_node.vmid },
    { for worker in local.worker_nodes : worker.name => worker.vmid },
    { for worker in local.gpu_worker_nodes : worker.name => worker.vmid }
  )
}

output "talos_control_plane_endpoints" {
  description = "Stable list of control-plane endpoints for Talos bootstrap workflows."
  value       = [local.control_plane_node.ip]
}

output "talos_bootstrap_nodes" {
  description = "Stable node metadata grouped by role for Talos bootstrap consumers."
  value = {
    control_plane = [local.control_plane_node]
    workers       = local.worker_nodes
    gpu_workers   = local.gpu_worker_nodes
  }
}

output "talos_node_ip_map" {
  description = "Stable node name to IP map for bootstrap handoff and diagnostics."
  value       = local.node_ip_map
}

output "talos_node_vmid_map" {
  description = "Stable node name to Proxmox VMID map for bootstrap handoff and diagnostics."
  value       = local.node_vmid_map
}

output "talos_bootstrap_contract" {
  description = "Canonical Phase 2 output contract consumed by Phase 3 Talos bootstrap orchestration."
  value = {
    control_plane_endpoints = [local.control_plane_node.ip]
    nodes_by_role = {
      control_plane = [local.control_plane_node]
      workers       = local.worker_nodes
      gpu_workers   = local.gpu_worker_nodes
    }
    node_ip_map   = local.node_ip_map
    node_vmid_map = local.node_vmid_map
  }
}

output "control_plane_vmid" {
  description = "Deprecated compatibility output. Prefer talos_node_vmid_map or talos_bootstrap_contract."
  value       = local.control_plane_node.vmid
}

output "control_plane_vmids" {
  description = "Deprecated compatibility output. Prefer talos_bootstrap_nodes.control_plane."
  value       = [local.control_plane_node.vmid]
}

output "control_plane_ip" {
  description = "Deprecated compatibility output. Prefer talos_control_plane_endpoints."
  value       = local.control_plane_node.ip
}

output "control_plane_ips" {
  description = "Deprecated compatibility output. Prefer talos_control_plane_endpoints."
  value       = [local.control_plane_node.ip]
}

output "worker_vmids" {
  description = "Deprecated compatibility output. Prefer talos_bootstrap_nodes.workers."
  value       = [for worker in local.worker_nodes : worker.vmid]
}

output "worker_ips" {
  description = "Deprecated compatibility output. Prefer talos_bootstrap_nodes.workers."
  value       = [for worker in local.worker_nodes : worker.ip]
}

output "gpu_worker_vmids" {
  description = "Deprecated compatibility output. Prefer talos_bootstrap_nodes.gpu_workers."
  value       = [for worker in local.gpu_worker_nodes : worker.vmid]
}

output "gpu_worker_ips" {
  description = "Deprecated compatibility output. Prefer talos_bootstrap_nodes.gpu_workers."
  value       = [for worker in local.gpu_worker_nodes : worker.ip]
}

output "gpu_worker_bdfs" {
  description = "Deprecated compatibility output. Prefer talos_bootstrap_nodes.gpu_workers[*].gpu_pci_bdf."
  value       = [for worker in local.gpu_worker_nodes : worker.gpu_pci_bdf]
}
