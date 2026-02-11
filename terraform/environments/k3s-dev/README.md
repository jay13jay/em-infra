# k3s-dev environment

Purpose: provision VMs for a non-HA k3s development cluster. This environment creates:

- 1 control-plane VM (no k3s installation)
- 0..N non-GPU workers (controlled by `worker_count`)
- 0..N GPU workers (one per PCI BDF listed in `gpu_worker_pci_bdfs`)

Important notes:
- This environment only provisions VMs. It does not install k3s or perform any in-guest provisioning beyond SSH key injection and optional `ipconfig0`.
- GPU workers are created one-per-PCI BDF. To scale GPU workers add/remove entries in `gpu_worker_pci_bdfs`.
- The `gpu_worker` module expects the GPU to be bound on the host (see `modules/gpu_worker/README.md`). Terraform will not rebind host devices.

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
- Add cloud-init or provisioners to install k3s on the control-plane and join workers.
- Implement a `modules/cluster` wrapper to encapsulate bootstrap logic and token propagation.
