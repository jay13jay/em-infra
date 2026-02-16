# EM-Infra MVP — Single-Host Proxmox Kubernetes Dev Environment Roadmap

**Owner:** Solo developer + AI assistants  
**Start Date:** 2026-02-16  
**Target MVP Completion:** 30 working days from start  
**Status:** In planning / implementation kickoff

---

## Executive Summary

This roadmap defines the infrastructure MVP for this repository:

- **Platform:** one Proxmox host
- **Cluster topology:** non-HA k3s (1 control plane + workers + GPU workers)
- **Provisioning model:** Terraform provisions VMs
- **Configuration model:** Ansible configures k3s and node roles
- **Primary objective:** fast, reproducible local development environment with minimal operator friction

### Automation Contract (Locked for MVP)

1. **Prepare template** (cloud-init capable Ubuntu template with guest agent)
2. **Provision VMs** in Proxmox via Terraform
3. **Generate/resolve inventory** from Terraform state (dynamic plugin canonical)
4. **Configure cluster** via Ansible (`site.yml`)
5. **Validate cluster** and deploy minimal dev workload

### What this roadmap is optimizing for

- Fast iteration for a solo developer
- Repeatable bring-up/tear-down
- Local-state workflow (no remote backend required for MVP)
- Clear runbooks for happy path and troubleshooting path

### Out of scope for this MVP

- HA control plane / external datastore
- Multi-host Proxmox orchestration
- Full GitOps platform rollout
- Production-grade secrets backend integration

---

## Current Baseline (Already in Repo)

### Preparation

- Template prep shell automation: `scripts/prepare_template.sh`
- Template prep Ansible playbook: `ansible/playbooks/prepare-template.yml`
- Supplemental prep helper: `scripts/prepare_template_ansible.sh`

### Provisioning

- Environment provisioning: `terraform/environments/k3s-dev/main.tf`
- Core Ubuntu VM module: `terraform/modules/vm_ubuntu22/`
- GPU worker module: `terraform/modules/gpu_worker/`
- Output contract for inventory groups: `control_plane_ips`, `worker_ips`, `gpu_worker_ips`

### Configuration

- Cluster bootstrap playbooks: `ansible/playbooks/site.yml`, `ansible/playbooks/control-plane.yml`, `ansible/playbooks/workers.yml`
- Shared vars: `ansible/group_vars/all.yml`

### Architecture contract

- Locked boundary document: `docs/architecture-freeze.md`

### Known baseline gaps to close

- Confirm and validate canonical dynamic inventory config at `ansible/inventory/terraform_inventory.yml`
- Root Terraform README is partly outdated vs current environment reality
- Provider version string drift between root and environment provider constraints
- No unified orchestrator script for one-command end-to-end run

---

## 30-Working-Day Timeline

## Phase 1 (Days 1-7): Foundations & Contract Alignment

### Goal

Make sure docs and automation contracts match actual code so day-to-day execution is deterministic.

### Tasks

- [ ] Add canonical dynamic inventory config at `ansible/inventory/terraform_inventory.yml`
- [ ] Add local-state example inventory config if needed (`ansible/inventory/terraform_state_local_example.yml`)
- [ ] Reconcile provider version pinning in:
  - `terraform/providers.tf`
  - `terraform/environments/k3s-dev/providers.tf`
- [ ] Update Terraform docs to reflect actual VM provisioning behavior:
  - `terraform/README.md`
  - `terraform/environments/k3s-dev/README.md` (if needed)
- [ ] Validate architecture references across docs (`README.md`, `ansible/README.md`, `docs/architecture-freeze.md`)

### Gate: Phase 1 completion

- [ ] `ansible-inventory -i ansible/inventory/terraform_inventory.yml --list` runs successfully
- [ ] `terraform -chdir=terraform/environments/k3s-dev validate` passes
- [ ] Docs no longer conflict about VM/resource scope

---

## Phase 2 (Days 8-14): Provisioning Reliability (Terraform)

### Goal

Make VM provisioning on a single Proxmox host predictable and safe to rerun.

### Tasks

- [ ] Confirm and document minimum input set (`terraform.tfvars.example`) for:
  - control plane
  - worker count
  - GPU worker PCI BDF list
- [ ] Harden variable validation (CIDR, template names, required IDs)
- [ ] Add/verify explicit output docs consumed by Ansible inventory
- [ ] Define local-state operational rules for solo dev:
  - state file location
  - backup cadence
  - restore steps
- [ ] Validate idempotent `plan/apply` behavior for no-op reruns

### Gate: Phase 2 completion

- [ ] `terraform plan` succeeds from clean clone + tfvars
- [ ] `terraform apply` creates expected VM topology
- [ ] second `terraform plan` reports no unintended drift

---

## Phase 3 (Days 15-21): Cluster Config Reliability (Ansible)

### Goal

Ensure Ansible reliably installs/joins k3s roles from Terraform-derived inventory.

### Tasks

- [ ] Validate role/playbook idempotency for:
  - control plane install
  - worker join
  - GPU worker group handling
- [ ] Add preflight checks (SSH reachability, sudo, network/API readiness)
- [ ] Add explicit post-run checks for node readiness
- [ ] Define failure semantics and rerun behavior in docs (what is safe to rerun, when to clean)
- [ ] Document expected group mapping contract in one place

### Gate: Phase 3 completion

- [ ] `ansible-playbook -i ansible/inventory/terraform_inventory.yml ansible/playbooks/site.yml` succeeds
- [ ] rerunning playbook causes no harmful changes
- [ ] `kubectl get nodes` shows expected control/worker/GPU node set

---

## Phase 4 (Days 22-26): Unified Execution UX

### Goal

Provide both one-command happy path and phased troubleshooting path.

### Tasks

- [ ] Add a top-level orchestrator entrypoint (example target: `scripts/provision_dev_env.sh`)
- [ ] Implement staged execution with clear checkpoints:
  - prepare
  - provision
  - configure
  - verify
- [ ] Add flags for phase-only execution (`--prepare-only`, `--terraform-only`, etc.)
- [ ] Emit structured logs/artifacts for each stage
- [ ] Add destroy/recovery entrypoint for rapid reset

### Gate: Phase 4 completion

- [ ] one-command run completes from prerequisites to validated cluster
- [ ] phased mode can recover from a failed intermediate stage
- [ ] operator can reset environment in bounded time

---

## Phase 5 (Days 27-30): Validation, Documentation, Day-2 Ops

### Goal

Ship an operationally usable infrastructure MVP with clear runbooks.

### Tasks

- [ ] Add validation checklist and smoke-test commands in docs
- [ ] Add day-2 runbook:
  - scale workers
  - add/remove GPU worker
  - rotate SSH key
  - retemplate workflow
- [ ] Add break/fix runbook for top 5 likely failures
- [ ] Cross-link all docs so operator path is linear from root README

### Gate: MVP done

- [ ] New developer can follow docs and bring up environment on one Proxmox host
- [ ] End-to-end automation path is reproducible
- [ ] Recovery and teardown paths are documented and tested

---

## Canonical Command Paths

## Happy path (target UX)

```bash
# One command (after prerequisites)
./scripts/provision_dev_env.sh
```

## Phased troubleshooting path

```bash
# 1) Template prep
./scripts/prepare_template.sh ...

# 2) Provision VMs
terraform -chdir=terraform/environments/k3s-dev init
terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars
terraform -chdir=terraform/environments/k3s-dev apply -var-file=terraform.tfvars

# 3) Inspect inventory
ansible-inventory -i ansible/inventory/terraform_inventory.yml --list

# 4) Configure cluster
ansible-playbook -i ansible/inventory/terraform_inventory.yml ansible/playbooks/site.yml

# 5) Verify cluster
kubectl get nodes -o wide
```

---

## Risks & Mitigations

### Risk 1: Inventory drift / missing plugin config

- **Impact:** Ansible cannot target Terraform-provisioned hosts
- **Mitigation:** ship canonical `terraform_inventory.yml`, validate in Phase 1 gate

### Risk 2: Local terraform state corruption or accidental loss

- **Impact:** drift, orphaned resources, destructive recovery
- **Mitigation:** define local backup/restore routine; do not commit state artifacts

### Risk 3: GPU passthrough host prerequisites not met

- **Impact:** GPU worker provisioning fails or is unusable
- **Mitigation:** preflight checklist + explicit host verification in runbook

### Risk 4: Partial-run failures (mid pipeline)

- **Impact:** manual cleanup needed, slower dev velocity
- **Mitigation:** phased mode + checkpointed orchestrator + destroy/reset command

### Risk 5: Shell-heavy tasks reduce idempotency confidence

- **Impact:** reruns create inconsistent state
- **Mitigation:** add explicit idempotency tests in Phase 3 and tighten task guards

---

## MVP Success Criteria

- [ ] One Proxmox host can reproducibly create: 1 control plane + N workers + N GPU workers
- [ ] Terraform output contract feeds Ansible inventory without manual host editing
- [ ] Ansible cluster configuration is rerunnable without destructive side effects
- [ ] One-command and phased execution modes both documented and functional
- [ ] Validation + teardown runbooks keep troubleshooting time low

---

## Deferred (Post-MVP)

- Remote Terraform backend + state locking
- CI pipeline automation for infra checks
- Full secrets manager integration
- HA topology / multi-control-plane path
- GitOps bootstrap (Flux/ArgoCD)

---

## Weekly Operating Rhythm (Solo)

- **Monday:** execute planned infra milestone tasks
- **Tuesday–Thursday:** implement + validate + rerun idempotency checks
- **Friday:** update docs, track blockers, decide keep/cut for next week
- **Daily closeout:** log pass/fail for each gate-related check command

---

## Implementation Tracker

### Immediate next actions (kickoff)

- [ ] Create `ansible/inventory/terraform_inventory.yml`
- [ ] Align Terraform provider version constraints
- [ ] Update Terraform README to match current repository state
- [ ] Add top-level orchestrator script skeleton
- [ ] Add validation checklist section to root README

