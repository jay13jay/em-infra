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

## Local State Operations (MVP, Solo Workflow)

Canonical state location:

- Primary state file: `terraform/environments/k3s-dev/terraform.tfstate`
- Terraform-managed rolling backup: `terraform/environments/k3s-dev/terraform.tfstate.backup`
- Optional operator snapshots: `terraform/environments/k3s-dev/state-backups/`

Non-commit rules:

- State artifacts and variable files are local-only and must never be committed.
- Repository ignore rules already exclude `*.tfstate`, `*.tfstate.*`, `*.tfvars`, and `*.tfvars.json`.

Backup cadence (minimum):

- Required: take a timestamped snapshot immediately before any `apply`, `destroy`, `import`, or `terraform state` mutation (`mv`/`rm`).
- Required: take one end-of-day snapshot if infrastructure was changed.

Example backup commands (from repository root):

```bash
mkdir -p terraform/environments/k3s-dev/state-backups
ts=$(date +%Y%m%d-%H%M%S)
cp terraform/environments/k3s-dev/terraform.tfstate \
    terraform/environments/k3s-dev/state-backups/terraform.tfstate.$ts
```

Pre-apply sanity checks:

```bash
test -f terraform/environments/k3s-dev/terraform.tfstate && terraform -chdir=terraform/environments/k3s-dev state list || true
terraform -chdir=terraform/environments/k3s-dev validate
terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars
```

Restore routine (from a known-good backup):

1. Stop all Terraform writes for this environment.
2. Preserve the current state copy before replacing it:
     ```bash
     cp terraform/environments/k3s-dev/terraform.tfstate terraform/environments/k3s-dev/terraform.tfstate.pre-restore.$(date +%Y%m%d-%H%M%S)
     ```
3. Restore the selected snapshot to the canonical state path:
     ```bash
     cp terraform/environments/k3s-dev/state-backups/terraform.tfstate.<timestamp> terraform/environments/k3s-dev/terraform.tfstate
     ```
4. Re-initialize and verify state readability:
     ```bash
     terraform -chdir=terraform/environments/k3s-dev init -input=false
     terraform -chdir=terraform/environments/k3s-dev state list
     ```
5. Run `plan` and confirm output matches expected live topology before any `apply`.

After accidental state loss:

- If a recent snapshot exists, follow the restore routine above.
- If no usable snapshot exists, choose one of:
    - Reconcile via `terraform import` for resources that must be preserved.
    - For rapid MVP recovery, perform controlled recreate (destroy/re-apply) if preserving current VMs is not required.

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
- Terraform 1.14.x (tested with 1.14.5; pinned in configuration)
- Proxmox Provider (Telmate/proxmox) 3.0.2-rc07 (current Telmate release tag)
