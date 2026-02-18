# k3s-dev environment

**Architecture:** See [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../../../docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md) for the Talos architecture contract.

Purpose: provision VMs for a non-HA Talos Kubernetes development cluster. This environment creates:

- 1 control-plane VM (cluster bootstrap handled outside Terraform)
- 0..N non-GPU workers (controlled by `worker_count`)
- 0..N GPU workers (one per PCI BDF listed in `gpu_worker_pci_bdfs`)

Important notes:
- This environment provisions VMs only. Terraform manages VM lifecycle and host resources; Talos is responsible for node OS configuration and runtime state (bootstrapping and in-cluster lifecycle).
- GPU workers are created one-per-PCI BDF. To scale GPU workers add/remove entries in `gpu_worker_pci_bdfs`.
- The `gpu_worker` module expects the GPU to be bound on the host (see `modules/gpu_worker/README.md`). Terraform will not rebind host devices.
- Base template preparation is an Ansible pre-step. Use `ansible/playbooks/prepare-template.yml` and `ansible/README_PREPARE_TEMPLATE.md`.
- Canonical template naming is `talos-v<major>.<minor>.<patch>-base` (example: `talos-v1.12.4-base`).
- **Phase 2 output contract is stable** via `talos_bootstrap_contract` and related `talos_*` outputs.
- For Talos workflows, do not treat guest-agent-derived IP fields as canonical runtime discovery.
- Prefer static/reserved addressing and post-bootstrap discovery via `talosctl`.

Minimum input set (MVP):

- Required provider auth: `proxmox_api_url`, `proxmox_api_token_id`, `proxmox_api_token_secret`
- Required placement and control-plane template: `node`, `control_plane_template`
- Required topology controls:
	- non-GPU workers: `worker_count` (set `0..N`; if `>0`, set `worker_template`)
	- GPU workers: `gpu_worker_pci_bdfs` (set `[]` for none; one worker per BDF)
	- when `gpu_worker_pci_bdfs` is non-empty, set `gpu_worker_template`

See `terraform/environments/k3s-dev/terraform.tfvars.example` for canonical variable names and baseline values.

Usage:

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update credentials and templates.

2. From the repo root run (recommended):

```bash
terraform -chdir=terraform/environments/k3s-dev init
terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars
terraform -chdir=terraform/environments/k3s-dev apply -var-file=terraform.tfvars
```

3. After apply, view outputs:

```bash
terraform -chdir=terraform/environments/k3s-dev output
```

Phase 2 bootstrap output contract (stable names):

- `talos_control_plane_endpoints`: list of control-plane endpoint IPs for Talos bootstrap entrypoints
- `talos_bootstrap_nodes`: role-grouped node objects (`control_plane`, `workers`, `gpu_workers`) with `name`, `vmid`, `ip`, `node` and GPU `gpu_pci_bdf` where applicable
- `talos_node_ip_map`: map of node name to IP
- `talos_node_vmid_map`: map of node name to Proxmox VMID
- `talos_bootstrap_contract`: canonical composite object that includes all the above in one machine-consumable payload

Example machine-consumable retrieval:

```bash
terraform -chdir=terraform/environments/k3s-dev output -json talos_bootstrap_contract
terraform -chdir=terraform/environments/k3s-dev output -json talos_bootstrap_nodes
```

Backward-compatibility note:

- Legacy outputs (`control_plane_ips`, `worker_ips`, `gpu_worker_ips`, and related VMID/BDF outputs) remain available for existing workflows but are deprecated in favor of the `talos_*` contract.

MVP local state guardrails:

- Canonical state path: `terraform/environments/k3s-dev/terraform.tfstate`.
- Terraform rolling backup path: `terraform/environments/k3s-dev/terraform.tfstate.backup`.
- Optional operator snapshots path: `terraform/environments/k3s-dev/state-backups/`.
- Keep `terraform.tfvars` and all state artifacts out of version control.

Backup cadence:

- Always snapshot state before `apply`, `destroy`, `import`, or `terraform state rm/mv`.
- Snapshot at end-of-day after successful infrastructure changes.

Backup command (repo root):

```bash
mkdir -p terraform/environments/k3s-dev/state-backups
ts=$(date +%Y%m%d-%H%M%S)
cp terraform/environments/k3s-dev/terraform.tfstate \
  terraform/environments/k3s-dev/state-backups/terraform.tfstate.$ts
```

Pre-apply safety checks:

```bash
test -f terraform/environments/k3s-dev/terraform.tfstate && terraform -chdir=terraform/environments/k3s-dev state list || true
terraform -chdir=terraform/environments/k3s-dev validate
terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars
```

Restore procedure:

1. Stop concurrent Terraform operations for this environment.
2. Preserve the current state copy:
	```bash
	cp terraform/environments/k3s-dev/terraform.tfstate terraform/environments/k3s-dev/terraform.tfstate.pre-restore.$(date +%Y%m%d-%H%M%S)
	```
3. Restore selected backup snapshot:
	```bash
	cp terraform/environments/k3s-dev/state-backups/terraform.tfstate.<timestamp> terraform/environments/k3s-dev/terraform.tfstate
	```
4. Reinitialize and verify state readability:
	```bash
	terraform -chdir=terraform/environments/k3s-dev init -input=false
	terraform -chdir=terraform/environments/k3s-dev state list
	```
5. Run plan and confirm expected topology before applying further changes.

If state is accidentally lost:

- Preferred: restore the latest known-good snapshot.
- If no usable snapshot exists, either import preserved VMs into a rebuilt state or perform a controlled rebuild for MVP workflows.

Scaling GPU workers:

- Edit `gpu_worker_pci_bdfs` in your tfvars to add or remove PCI BDF strings, then `terraform apply`.

Next steps (outside scope):
- Add Talos machine config generation and bootstrap orchestration.
- Implement a `modules/cluster` wrapper to encapsulate Talos-oriented bring-up flow.
