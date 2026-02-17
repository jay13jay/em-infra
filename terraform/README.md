# Terraform — Proxmox Infrastructure

This directory contains the Terraform configuration for the Proxmox infrastructure.
It is organized into environments and modules.

Terraform manages VM lifecycle only — it creates and configures virtual machines and host-level resources; Talos is solely responsible for node OS configuration and runtime state (bootstrapping, OS configuration, and kubelet/runtime lifecycle).

## Structure

```
terraform/
├── environments/       # Environment-specific configurations (state roots)
│   └── k3s-dev/        # The main development environment
├── modules/            # Reusable Terraform modules
│   ├── cluster/
│   ├── gpu_worker/
│   └── vm_ubuntu22/
└── providers.tf        # Root provider configuration (reference)
```

## Quick Start (k3s-dev)

1.  **From repository root, initialize the environment:**
    ```bash
    terraform -chdir=terraform/environments/k3s-dev init
    ```

2.  **Configure Variables:**
    Copy `terraform/environments/k3s-dev/terraform.tfvars.example` to `terraform/environments/k3s-dev/terraform.tfvars` and edit it with your Proxmox credentials and settings.
    ```bash
    cp terraform/environments/k3s-dev/terraform.tfvars.example terraform/environments/k3s-dev/terraform.tfvars
    ```

3.  **Plan and Apply:**
    ```bash
    terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars
    terraform -chdir=terraform/environments/k3s-dev apply -var-file=terraform.tfvars
    ```

## Local State Expectations (MVP)

- State is local to `terraform/environments/k3s-dev/terraform.tfstate`.
- Keep state backups before major changes:
  ```bash
  cp terraform/environments/k3s-dev/terraform.tfstate terraform/environments/k3s-dev/terraform.tfstate.backup.$(date +%Y%m%d-%H%M%S)
  ```
- Treat `terraform.tfvars` and state files as sensitive and do not commit them.

## Outputs
The `k3s-dev` environment outputs remain available for orchestration and diagnostics.
Key outputs include:
- `talos_bootstrap_contract`
- `talos_control_plane_endpoints`
- `talos_node_ip_map`
- `talos_node_vmid_map`

Legacy outputs (`control_plane_ips`, `worker_ips`, `gpu_worker_ips`, and related VMID/BDF outputs) remain for compatibility but are deprecated in favor of the `talos_*` contract.

For Talos workflows, these outputs are not the canonical post-boot source of cluster state.
Use `talosctl` to retrieve node membership and cluster access details after bootstrap.

## Talos Node Discovery (Preferred)

Talos does not support `qemu-guest-agent`, so workflows should not rely on Terraform dynamic inventory
that composes host IPs from guest-agent fields.

Recommended approach:

1. Define predictable node addressing in your cluster intent (static IPs or DHCP reservations).
2. Provision VMs with Terraform.
3. Bootstrap Talos.
4. Retrieve live node/cluster information with `talosctl`.

Example:

```bash
# Show Talos member view after bootstrap
talosctl --talosconfig <path-to-talosconfig> --endpoints <control-plane-ip> --nodes <control-plane-ip> get members

# Retrieve kubeconfig from Talos
talosctl --talosconfig <path-to-talosconfig> --endpoints <control-plane-ip> kubeconfig ./kubeconfig
```

## Requirements
- Terraform >= 1.3.0
- Proxmox Provider (Telmate/proxmox) 3.0.2-rc07
