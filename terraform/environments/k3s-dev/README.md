# k3s-dev environment

**Architecture:** See [docs/EM-Infra-Talos-Proxmox-Architecture.md](../../../docs/EM-Infra-Talos-Proxmox-Architecture.md) for the Talos architecture contract.

Purpose: provision VMs for a non-HA Talos Kubernetes development cluster. This environment creates:

- 1 control-plane VM (cluster bootstrap handled outside Terraform)
- 0..N non-GPU workers (controlled by `worker_count`)
- 0..N GPU workers (one per PCI BDF listed in `gpu_worker_pci_bdfs`)

Important notes:
- This environment only provisions VMs. It does not perform Talos bootstrap or post-cluster addon installation.
- GPU workers are created one-per-PCI BDF. To scale GPU workers add/remove entries in `gpu_worker_pci_bdfs`.
- The `gpu_worker` module expects the GPU to be bound on the host (see `modules/gpu_worker/README.md`). Terraform will not rebind host devices.
- **Outputs are list-valued** for orchestration compatibility: `control_plane_ips`, `worker_ips`, `gpu_worker_ips`.
- For Talos workflows, do not treat guest-agent-derived IP fields as canonical runtime discovery.
- Prefer static/reserved addressing and post-bootstrap discovery via `talosctl`.

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

Scaling GPU workers:

- Edit `gpu_worker_pci_bdfs` in your tfvars to add or remove PCI BDF strings, then `terraform apply`.

Next steps (outside scope):
- Add Talos machine config generation and bootstrap orchestration.
- Implement a `modules/cluster` wrapper to encapsulate Talos-oriented bring-up flow.
