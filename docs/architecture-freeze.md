# Phase 0: Architecture Freeze

**Status:** Locked  
**Date:** 2026-02-12  
**Purpose:** Define contracts between Terraform, Ansible, and Kubernetes for the k3s-dev environment

---

## Overview

This document defines the **architectural boundaries and contracts** between infrastructure layers:

- **Terraform**: Provisions VMs on Proxmox
- **Ansible**: Configures k3s cluster on provisioned VMs
- **Kubernetes**: Runs workloads on the k3s cluster

**Key Design Decision:** Non-HA, single control-plane k3s cluster for development.

---

## 1. Node Roles

### Control Plane (`k3s_control`)
- **Count:** 1 (single node, non-HA)
- **Purpose:** Run k3s server and embedded datastore (SQLite)
- **Ansible Group:** `k3s_control`
- **Terraform Output:** `control_plane_ips` (single-item list)
- **Template:** Ubuntu 22.04 LTS cloud-init template with qemu-guest-agent

### Worker Nodes (`k3s_workers`)
- **Count:** Variable (`worker_count`, default 0)
- **Purpose:** Run standard k3s agent workloads
- **Ansible Group:** `k3s_workers`
- **Terraform Output:** `worker_ips` (list)
- **Template:** Ubuntu 22.04 LTS cloud-init template with qemu-guest-agent

### GPU Worker Nodes (`k3s_gpu`)
- **Count:** One per entry in `gpu_worker_pci_bdfs` list
- **Purpose:** Run GPU-accelerated workloads
- **Ansible Group:** `k3s_gpu`
- **Terraform Output:** `gpu_worker_ips` (list)
- **Identification:** By Ansible group membership (`k3s_gpu`)
- **Template:** Ubuntu 22.04 LTS cloud-init template with qemu-guest-agent
- **GPU Attachment:** PCI passthrough (hostpci0) using provided BDF

---

## 2. Cluster Topology

### Control Plane
- **Topology:** Single node (non-HA)
- **Datastore:** SQLite (embedded in k3s server)
- **No external datastore** (no etcd, no MySQL/PostgreSQL)
- **API Endpoint:** `https://<control_plane_ip>:6443`

### High Availability
- **HA:** Not supported in this architecture
- **Rationale:** Development environment; simplicity over resilience

---

## 3. Network Configuration

### Node Network
- **Bridge:** `network_bridge` variable (default: `vmbr0`)
- **IP Assignment:** DHCP (default) or static via `static_ip_map`
- **Node CIDR:** Optional `cluster_network_cidr` variable for validation (e.g., `192.168.1.0/24`)

### Kubernetes Networking
- **Pod Network CIDR:** `cluster_cidr` variable (default: `10.42.0.0/16`, k3s default)
- **Service Network CIDR:** `service_cidr` variable (default: `10.43.0.0/16`, k3s default)
- **CNI:** k3s default (Flannel with VXLAN backend)

### Static IP Requirements
- Control plane should have predictable IP (use `static_ip_map` or DHCP reservation)
- Workers can use DHCP
- Format: `static_ip_map = { "vm-name" = "ip=192.168.1.10/24,gw=192.168.1.1" }`

---

## 4. SSH and Access

### SSH Key Contract
- **Terraform:** Injects public keys via `ssh_authorized_keys` variable
- **Ansible:** Expects matching private key at `ssh_private_key_file` (default: `~/.ssh/id_rsa`)
- **SSH User:** `ubuntu` (cloud-init default on Ubuntu LTS)
- **Sudo:** Passwordless sudo required (Ubuntu cloud-init default)

### Operator Responsibilities
1. Generate SSH keypair (if not exists): `ssh-keygen -t rsa -b 4096`
2. Add public key to `terraform.tfvars`: `ssh_authorized_keys = ["ssh-rsa AAAA..."]`
3. Ensure private key path matches `ansible/group_vars/all.yml`: `ssh_private_key_file`
4. Alternative: Use SSH agent and configure Ansible to use agent forwarding

---

## 5. OS Image Requirements

### Template Prerequisites
- **OS:** Ubuntu 22.04 LTS (minimal/server image)
- **Cloud-init:** Must be installed and enabled
- **QEMU Guest Agent:** Required (`qemu-guest-agent` package)
- **Cloud-init datasource:** NoCloud or ConfigDrive (Proxmox compatible)

### Proxmox Template Naming
- Variable: `control_plane_template`, `worker_template`, `gpu_worker_template`
- Format: Template name or VMID (e.g., `ubuntu-22-cloudinit-template` or `9000`)

### Example Template Creation
```bash
# Download Ubuntu cloud image
wget https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img

# Create Proxmox VM template (adjust IDs and storage)
qm create 9000 --name ubuntu-22-cloudinit-template --memory 2048 --net0 virtio,bridge=vmbr0
qm importdisk 9000 ubuntu-22.04-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1
qm template 9000
```

---

## 6. Container Runtime

### Runtime
- **k3s** (includes embedded containerd)
- **Version:** Controlled by `k3s_version` in `ansible/group_vars/all.yml` (empty = latest)
- **Socket:** `/run/k3s/containerd/containerd.sock`

### k3s Installation
- **Installer:** k3s install script (`https://get.k3s.io`)
- **Control Plane:** `curl -sfL https://get.k3s.io | sh -s - server`
- **Workers:** `curl -sfL https://get.k3s.io | sh -s - agent`

### k3s Configuration
- **Embedded Components:** CoreDNS, Metrics Server, Local Path Provisioner
- **Disabled Components:** Traefik (controlled by `k3s_disable_traefik: true`)
- **Kubeconfig:** `/etc/rancher/k3s/k3s.yaml` (root-readable by default)

---

## 7. GPU Worker Prerequisites

### Host-side Requirements (Operator Manual Steps)
1. **IOMMU Enabled:** Kernel boot parameter `intel_iommu=on` or `amd_iommu=on`
2. **VFIO Modules Loaded:**
   ```bash
   modprobe vfio vfio-pci vfio_iommu_type1
   ```
3. **GPU Bound to vfio-pci:** Use provided helper script
   ```bash
   cd terraform/modules/gpu_worker/files
   sudo ./bind_gpu.sh 0000:03:00.0
   ```
4. **Verify Binding:**
   ```bash
   lspci -nnk -s 0000:03:00.0
   ```

### Terraform GPU Module Behavior
- **Scope:** Provisions VM with PCI passthrough configuration
- **Does NOT:** Bind host GPU drivers, install guest GPU drivers, configure IOMMU
- **Operator Responsibility:** Complete host-side prerequisites before `terraform apply`

### Guest-side GPU Drivers (Post-Ansible)
- **Not automated:** Operator must install NVIDIA/AMD drivers in GPU worker VMs
- **Example (NVIDIA):**
  ```bash
  ssh ubuntu@<gpu_worker_ip>
  sudo apt update && sudo apt install -y nvidia-driver-535
  sudo reboot
  ```

---

## 8. Terraform Output Contract

### Required Outputs (for Ansible Inventory)
```hcl
output "control_plane_ips" {
  description = "List of control plane IPs (single-item list for non-HA)"
  value       = [module.control_plane.ip_address]
}

output "worker_ips" {
  description = "List of worker node IPs"
  value       = [for m in module.workers: m.ip_address]
}

output "gpu_worker_ips" {
  description = "List of GPU worker node IPs"
  value       = [for m in values(module.gpu_workers): m.ip_address]
}
```

### Deprecated Outputs (for compatibility)
- `control_plane_ip` (scalar) — use `control_plane_ips[0]`
- `control_plane_vmid` (scalar) — use `control_plane_vmids[0]`

### Additional Outputs
- `control_plane_vmids`, `worker_vmids`, `gpu_worker_vmids`: Proxmox VM IDs
- `gpu_worker_bdfs`: List of PCI BDFs for GPU workers

---

## 9. Ansible Inventory Schema

### Inventory Plugin
- **Plugin:** `community.general.terraform` or Ansible terraform inventory plugin
- **Path:** `../../terraform/environments/k3s-dev`
- **File:** `ansible/inventory/terraform_inventory.yml`

### Group Mapping
```yaml
groups:
  k3s_control: control_plane_ips
  k3s_workers: worker_ips
  k3s_gpu: gpu_worker_ips
```

### Expected Structure
```json
{
  "k3s_control": {
    "hosts": ["192.168.1.10"]
  },
  "k3s_workers": {
    "hosts": ["192.168.1.11", "192.168.1.12"]
  },
  "k3s_gpu": {
    "hosts": ["192.168.1.20"]
  }
}
```

### Validation
```bash
cd ansible
ansible-inventory -i inventory/terraform_inventory.yml --list
```

---

## 10. Base Cluster Feature List

### Included (Installed by Ansible)
- ✅ k3s server (control plane)
- ✅ k3s agent (workers)
- ✅ CoreDNS
- ✅ Metrics Server
- ✅ Local Path Provisioner (default StorageClass)
- ✅ Kubeconfig setup (`/etc/rancher/k3s/k3s.yaml`)

### Excluded (Not Installed)
- ❌ Traefik ingress controller (`k3s_disable_traefik: true`)
- ❌ External load balancer (use MetalLB or NodePort)
- ❌ Persistent volume provisioner (use Local Path or external CSI)
- ❌ Monitoring stack (install separately: Prometheus, Grafana)
- ❌ Logging stack (install separately: Loki, Fluent Bit)
- ❌ GPU operators (install separately: NVIDIA GPU Operator, device plugins)

### Future Considerations (Out of Scope for Phase 0)
- Backup/restore (Velero)
- Service mesh (Istio, Linkerd)
- GitOps (Flux, ArgoCD)
- Certificate management (cert-manager)

---

## Breakpoint 0: Confirmation Checklist

**Confirm the following before proceeding to Phase 1:**

- [ ] **Node Roles Correct**
  - Single control plane (`k3s_control`)
  - Variable number of standard workers (`k3s_workers`)
  - GPU workers identified by group (`k3s_gpu`)

- [ ] **No HA**
  - Single control plane node
  - SQLite datastore (no external etcd/database)
  - No load balancer for control plane API

- [ ] **No External Datastore**
  - k3s uses embedded SQLite
  - No MySQL, PostgreSQL, or etcd configuration

- [ ] **GPU Nodes Identified by Group**
  - Ansible group `k3s_gpu` maps to `gpu_worker_ips` output
  - One GPU per worker (enforced by `gpu_worker_pci_bdfs` list)
  - Host prerequisites documented and operator-managed

- [ ] **Terraform/Ansible Contracts Aligned**
  - Outputs are list-valued (`control_plane_ips`, `worker_ips`, `gpu_worker_ips`)
  - Inventory maps groups to outputs correctly
  - SSH keypair contract documented

- [ ] **Network CIDRs Documented**
  - Pod CIDR: `10.42.0.0/16` (k3s default)
  - Service CIDR: `10.43.0.0/16` (k3s default)
  - Node network: Variable (`cluster_network_cidr` optional)

- [ ] **OS Image Requirements Defined**
  - Ubuntu 22.04 LTS minimal
  - Cloud-init enabled
  - QEMU guest agent installed

- [ ] **Container Runtime Agreed**
  - k3s with embedded containerd
  - No separate Docker/containerd installation

---

## References

- **Terraform Environment:** [terraform/environments/k3s-dev/](../terraform/environments/k3s-dev/)
- **Terraform GPU Module:** [terraform/modules/gpu_worker/](../terraform/modules/gpu_worker/)
- **Ansible Playbooks:** [ansible/playbooks/](../ansible/playbooks/)
- **Ansible Inventory:** [ansible/inventory/terraform_inventory.yml](../ansible/inventory/terraform_inventory.yml)
- **k3s Documentation:** https://docs.k3s.io/

---

**Next Phase:** Phase 1 — Terraform Module Contracts and VM Provisioning Validation
