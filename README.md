# em-infra — infrastructure source of truth

Canonical infrastructure repository for Kubernetes-on-Proxmox using immutable Talos nodes.

This repo contains:

- Terraform for VM lifecycle management
- Ansible for host/template orchestration
- Kubernetes manifests and overlays
- Inventory and validation tooling
- Local developer workflows (Docker/Compose/Skaffold)

## Start Here

- Documentation index (canonical docs entrypoint): [docs/README.md](docs/README.md)
- Architecture contract: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- Active roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](docs/planning/infra-roadmap-single-host-k3s-dev.md)
- Active implementation tracker: [docs/implementation/phase-2/phase-2-implementation-tracker.md](docs/implementation/phase-2/phase-2-implementation-tracker.md)

## Runtime Versions (Pinned)

- Terraform: `1.14.5` (`>= 1.14.5, < 1.15.0`)
- Proxmox provider: `Telmate/proxmox 3.0.2-rc07`
- Talos: `v1.12.4`
- ansible-core: `2.20.2`

See full matrix in [docs/README.md](docs/README.md).

## Repository Map

- Terraform: [terraform/](terraform)
	- Main env: [terraform/environments/k3s-dev/](terraform/environments/k3s-dev)
	- Env runbook: [terraform/environments/k3s-dev/README.md](terraform/environments/k3s-dev/README.md)
- Ansible: [ansible/](ansible)
- Kubernetes manifests: [k8s/](k8s)
- Inventory intent files: [inventory/](inventory)
- Scripts/utilities: [scripts/](scripts)
- Documentation: [docs/](docs)

## Common Runbooks

From repo root, use the project Makefile wrappers (Dockerized Terraform with Windows/Git Bash path nuances handled):

```bash
make tf-init
make tf-validate
make tf-plan
make tf-apply
make tf-output-contract
```

Additional runbooks:

- Fast plan (no refresh): `make tf-plan-fast`
- State snapshot backup: `make tf-backup-state`
- Full verification gate (`init -> validate -> plan -> apply -> plan`): `make tf-gate`
- Show all targets: `make help`

## Local Dev Quickstart (Service Iteration)

- Compose-first local loop: `docker compose up --build`
- K8s-parity local loop (kind/k3d required): `skaffold dev -p dev`

## Infrastructure Workflow Notes

- Terraform manages VM lifecycle only; Talos owns node OS/runtime state.
- Inventory under [inventory/](inventory) is canonical intent.
- Use task docs + tracker evidence logging flow from [docs/README.md](docs/README.md) for implementation work.
- For Talos workflows, do not treat guest-agent-derived IPs as canonical runtime discovery.

## Additional Navigation

- New contributor onboarding: [docs/guides/onboarding.md](docs/guides/onboarding.md)
- Windows/WSL setup: [docs/guides/windows-dev.md](docs/guides/windows-dev.md)
- Phase task template: [docs/implementation/templates/task-doc-template.md](docs/implementation/templates/task-doc-template.md)

## Troubleshooting

### Terraform says `terraform.tfvars` does not exist

Cause:

- Running Docker Terraform from `terraform/environments/k3s-dev` while also using a `-w /workspace/terraform/environments/k3s-dev` path intended for repo-root execution.

Use:

- From repo root: `make tf-plan` (recommended)
- Or direct Docker from repo root:
	- `MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W):/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 plan -compact-warnings -var-file=terraform.tfvars`

### Warning: `Qemu Guest Agent support is disabled`

Status:

- Expected for Talos nodes in this repo.
- Talos does not rely on qemu-guest-agent for runtime node discovery.

Action:

- No action required for Talos workflows.

### Warning: `Redundant ignore_changes element` for `reboot_required`

Status:

- This is provider behavior around computed fields.

Action:

- If you prioritize strict no-op plans, keep current lifecycle ignores.
- If you prioritize zero warnings, remove `reboot_required` from ignore list and accept benign plan noise.

### Apply error: state lock or timed-out VM power action

Symptoms:

- `Error acquiring the state lock`
- `VM quit/powerdown failed - got timeout`

Action:

- Ensure no concurrent Terraform operation is running.
- Re-run with `make tf-plan` to inspect current drift.
- Use `make tf-backup-state` before any manual state operations.
