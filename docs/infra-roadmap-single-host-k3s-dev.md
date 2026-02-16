# EM-Infra MVP — Single-Host Proxmox Talos Kubernetes Dev Environment Roadmap

**Owner:** Solo developer + AI assistants  
**Start Date:** 2026-02-16  
**Target MVP Completion:** 30 working days from start  
**Status:** In planning / implementation kickoff

---

## Navigation

- Roadmap (execution sequencing): [docs/infra-roadmap-single-host-k3s-dev.md](./infra-roadmap-single-host-k3s-dev.md)
- Target architecture (technical contract): [docs/EM-Infra-Talos-Proxmox-Architecture.md](./EM-Infra-Talos-Proxmox-Architecture.md)

---

## Scope Alignment (Non-Conflict Contract)

This roadmap is aligned to the Talos architecture document.

- If a task in this roadmap conflicts with [docs/EM-Infra-Talos-Proxmox-Architecture.md](./EM-Infra-Talos-Proxmox-Architecture.md), the Talos architecture document is canonical.
- k3s/SSH node-configuration tasking is replaced by Talos machine-config generation + Talos bootstrap orchestration.
- Terraform still owns VM lifecycle only; node OS state is owned by Talos.

---

## Executive Summary

This roadmap defines the infrastructure MVP delivery path for this repository:

- **Platform:** one Proxmox host
- **Cluster topology:** non-HA Talos Kubernetes (1 control plane + workers + GPU workers)
- **Provisioning model:** Terraform provisions VMs
- **Configuration model:** Ansible orchestrates Talos config generation, bootstrap order, and post-cluster addons
- **Primary objective:** fast, reproducible local development environment with minimal operator friction

### Automation Contract (Locked for MVP)

1. **Prepare Talos template** in Proxmox
2. **Generate Talos machine configs** from inventory intent
3. **Provision VMs** in Proxmox via Terraform
4. **Bootstrap Talos cluster** via Ansible + `talosctl`
5. **Validate cluster and install baseline addons**

### What this roadmap is optimizing for

- Fast iteration for a solo developer
- Repeatable bring-up/tear-down
- Local-state workflow (no remote backend required for MVP)
- Clear runbooks for happy path and troubleshooting path

### Out of scope for this MVP

- HA control plane / multi-control-plane quorum
- Multi-host Proxmox orchestration
- Full GitOps platform rollout
- Production-grade secrets backend integration

---

## Current Baseline (Already in Repo)

### Preparation + provisioning baseline

- Template prep shell automation exists for current flow: `scripts/prepare_template.sh`
- Environment provisioning exists: `terraform/environments/k3s-dev/main.tf`
- Current VM modules exist and are usable as migration references:
  - `terraform/modules/vm_ubuntu22/`
  - `terraform/modules/gpu_worker/`

### Target architecture contract

- Canonical target architecture: `docs/EM-Infra-Talos-Proxmox-Architecture.md`
- Existing boundary document: `docs/architecture-freeze.md`

### Known baseline gaps to close

- Add/validate Talos inventory model and schema contract (`cluster.yaml`, `nodes.yaml`)
- Reconcile provider version pinning in root + environment Terraform configs
- Update Terraform docs to reflect Talos VM provisioning intent
- Add unified orchestrator script for one-command end-to-end run

---

## 30-Working-Day Timeline

## Phase 1 (Days 1-7): Foundations & Contract Alignment

### Goal

Make docs and automation contracts match a Talos-first implementation path.

### Tasks

- [ ] Add/validate canonical architecture cross-links in root + infra docs
- [ ] Define initial inventory intent files for dev (`cluster.yaml`, `nodes.yaml`)
- [ ] Reconcile provider version pinning in:
  - `terraform/providers.tf`
  - `terraform/environments/k3s-dev/providers.tf`
- [ ] Update Terraform docs to reflect Talos-oriented provisioning behavior:
  - `terraform/README.md`
  - `terraform/environments/k3s-dev/README.md` (if needed)

### Gate: Phase 1 completion

- [ ] Architecture and roadmap docs have no contradictory tasking
- [ ] `terraform -chdir=terraform/environments/k3s-dev validate` passes

---

## Phase 2 (Days 8-14): Provisioning Reliability (Terraform)

### Goal

Make Talos VM provisioning on a single Proxmox host predictable and safe to rerun.

### Tasks

- [ ] Confirm and document minimum input set (`terraform.tfvars.example`) for:
  - control plane
  - worker count
  - GPU worker PCI BDF list
- [ ] Harden variable validation (CIDR, template names, required IDs)
- [ ] Add/verify output contract required by Talos bootstrap orchestration
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

## Phase 3 (Days 15-21): Cluster Bootstrap Reliability (Talos + Ansible)

### Goal

Ensure Talos bootstrap is reliable, idempotent where expected, and safe to rerun.

### Tasks

- [ ] Validate config generation workflow (`talos-gen-config`) for controlplane/worker roles
- [ ] Add preflight checks (Proxmox reachability, Talos API readiness, required tooling)
- [ ] Validate bootstrap flow (`talos-bootstrap`) and kubeconfig retrieval
- [ ] Add explicit post-run checks for node readiness
- [ ] Define failure semantics and rerun behavior (safe rerun vs required clean rebuild)

### Gate: Phase 3 completion

- [ ] Talos bootstrap workflow succeeds end-to-end
- [ ] Rerun behavior is documented and non-destructive for supported steps
- [ ] `talosctl ... get members` returns expected node membership
- [ ] `kubectl get nodes` shows expected control/worker/GPU node set

---

## Phase 4 (Days 22-26): Unified Execution UX

### Goal

Provide both one-command happy path and phased troubleshooting path.

### Tasks

- [ ] Add a top-level orchestrator entrypoint (example target: `scripts/provision_dev_env.sh`)
- [ ] Implement staged execution with clear checkpoints:
  - generate-config
  - provision
  - bootstrap
  - verify
- [ ] Add flags for phase-only execution (`--generate-only`, `--terraform-only`, etc.)
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
  - rotate cluster credentials/secrets workflow
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
# 1) Generate Talos configs
docker compose run ansible ansible-playbook ansible/playbooks/talos-gen-config.yml

# 2) Provision VMs
docker compose run terraform terraform -chdir=terraform/dev apply

# 3) Bootstrap cluster
docker compose run ansible ansible-playbook ansible/playbooks/talos-bootstrap.yml

# 4) Retrieve cluster info (Talos-native)
talosctl --talosconfig <path-to-talosconfig> --endpoints <control-plane-ip> --nodes <control-plane-ip> get members
talosctl --talosconfig <path-to-talosconfig> --endpoints <control-plane-ip> kubeconfig ./kubeconfig

# 5) Configure post-cluster addons
docker compose run ansible ansible-playbook ansible/playbooks/kube-post.yml

# 6) Verify cluster
kubectl get nodes -o wide
```

---

## Risks & Mitigations

### Risk 1: Inventory intent and generated config drift

- **Impact:** provisioned nodes do not match intended topology
- **Mitigation:** keep inventory files canonical; validate generated outputs in Phase 1/3 gates

### Risk 2: Local terraform state corruption or accidental loss

- **Impact:** drift, orphaned resources, destructive recovery
- **Mitigation:** define local backup/restore routine; do not commit state artifacts

### Risk 3: GPU passthrough host prerequisites not met

- **Impact:** GPU worker provisioning fails or is unusable
- **Mitigation:** preflight checklist + explicit host verification in runbook

### Risk 4: Partial-run failures (mid pipeline)

- **Impact:** manual cleanup needed, slower dev velocity
- **Mitigation:** phased mode + checkpointed orchestrator + destroy/reset command

### Risk 5: Talos bootstrap ordering mistakes

- **Impact:** cluster creation stalls or partially initializes
- **Mitigation:** explicit bootstrap sequencing + readiness gates in automation

---

## MVP Success Criteria

- [ ] One Proxmox host can reproducibly create: 1 control plane + N workers + N GPU workers
- [ ] Inventory intent feeds Talos config generation without manual host edits
- [ ] Talos bootstrap/configuration flow is rerunnable without destructive side effects
- [ ] One-command and phased execution modes both documented and functional
- [ ] Validation + teardown runbooks keep troubleshooting time low

---

## Deferred (Post-MVP)

- Remote Terraform backend + state locking
- CI pipeline automation for infra checks
- Full secrets manager integration
- HA topology / multi-control-plane path
- Full GitOps bootstrap rollout

---

## Weekly Operating Rhythm (Solo)

- **Monday:** execute planned infra milestone tasks
- **Tuesday–Thursday:** implement + validate + rerun idempotency checks
- **Friday:** update docs, track blockers, decide keep/cut for next week
- **Daily closeout:** log pass/fail for each gate-related check command

---

## Implementation Tracker

### Immediate next actions (kickoff)

- [ ] Create initial dev inventory intent files (`cluster.yaml`, `nodes.yaml`)
- [ ] Align Terraform provider version constraints
- [ ] Update Terraform README to match Talos-target repository state
- [ ] Add top-level orchestrator script skeleton
- [ ] Add validation checklist section to root README

