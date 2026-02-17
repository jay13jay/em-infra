# EM-Infra Phase 1 Implementation Tracker — Foundations & Contract Alignment

**Owner:** Solo developer + AI assistants  
**Phase Window:** Days 1-7 (MVP roadmap)  
**Status:** Complete  
**Last Updated:** 2026-02-17

---

## Navigation

- Docs index: [docs/README.md](../README.md)
- Canonical architecture contract: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- MVP roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](../planning/infra-roadmap-single-host-k3s-dev.md)

---

## Phase 1 Objective

Align repository docs and baseline automation contracts to the Talos-first architecture so implementation can proceed without ownership ambiguity.

If any task below conflicts with the architecture document, [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../contracts/EM-Infra-Talos-Proxmox-Architecture.md) is canonical.

---

## Scope for This Phase

### In scope

- Documentation cross-link and contract consistency cleanup
- Initial inventory intent files for dev (`cluster.yaml`, `nodes.yaml`)
- Terraform provider version pinning reconciliation
- Terraform documentation updates for Talos VM lifecycle intent
- Validation gate execution and evidence capture

### Out of scope

- Full Talos bootstrap implementation details (Phase 3)
- Unified one-command orchestrator implementation (Phase 4)
- HA topology or multi-host Proxmox support

---

## Task Tracker

### Task documents

- P1-T1: [docs/implementation/phase-1-task-1-docs-cross-link-alignment.md](./phase-1-task-1-docs-cross-link-alignment.md)
- P1-T2: [docs/implementation/phase-1-task-2-dev-inventory-intent-files.md](./phase-1-task-2-dev-inventory-intent-files.md)
- P1-T3: [docs/implementation/phase-1-task-3-terraform-provider-version-reconciliation.md](./phase-1-task-3-terraform-provider-version-reconciliation.md)
- P1-T4: [docs/implementation/phase-1-task-4-terraform-docs-talos-provisioning-intent.md](./phase-1-task-4-terraform-docs-talos-provisioning-intent.md)

## 1) Docs & architecture cross-link alignment

**Goal:** Ensure operator path is linear and no docs contradict ownership boundaries.

**Planned changes**

- [ ] Add/verify cross-links in root and infra docs
- [ ] Establish canonical docs index/hierarchy entrypoint (`docs/README.md`)
- [ ] Remove/flag any wording that implies Terraform configures node OS
- [ ] Ensure all phase references align to Talos workflow naming

**Primary files**

- `README.md`
- `docs/planning/infra-roadmap-single-host-k3s-dev.md`
- `docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md`

**Done when**

- [ ] No contradictory ownership language remains
- [ ] Navigation path from root README to architecture + roadmap is explicit
- [ ] Docs index exists and is linked by major architecture/planning docs

---

## 2) Define initial dev inventory intent files

**Goal:** Establish canonical inventory intent inputs for later Talos config generation.

**Planned changes**

- [ ] Add `inventory/dev/cluster.yaml`
- [ ] Add `inventory/dev/nodes.yaml`
- [ ] Include minimal required fields for single-host dev topology
- [ ] Document expected ownership (inventory as source of truth)

**Primary files**

- `inventory/dev/cluster.yaml` (new)
- `inventory/dev/nodes.yaml` (new)
- `schema.json` (update if needed for validation contract)

**Done when**

- [ ] Files exist with valid YAML syntax
- [ ] Field names are consistent with architecture examples
- [ ] Intended control plane + worker + optional GPU worker model is representable

---

## 3) Reconcile Terraform provider version constraints

**Goal:** Remove version drift risk between root and environment provider configs.

**Planned changes**

- [ ] Compare provider blocks between root and `k3s-dev` environment
- [ ] Align required provider version constraints
- [ ] Align Terraform version constraint strategy where needed
- [ ] Verify init/validate succeeds after reconciliation

**Primary files**

- `terraform/providers.tf`
- `terraform/environments/k3s-dev/providers.tf`

**Done when**

- [ ] No conflicting provider constraints remain
- [ ] `terraform -chdir=terraform/environments/k3s-dev validate` passes

---

## 4) Update Terraform documentation for Talos provisioning intent

**Goal:** Make docs reflect current ownership boundary: Terraform manages VM lifecycle only.

**Planned changes**

- [ ] Update root Terraform docs to describe Talos-native flow
- [ ] Add/adjust environment README guidance for `k3s-dev`
- [ ] Ensure command examples use repository-real paths
- [ ] Document local-state expectations for MVP

**Primary files**

- `terraform/README.md`
- `terraform/environments/k3s-dev/README.md` (if present; otherwise create)

**Done when**

- [ ] Doc language matches architecture ownership model
- [ ] Operator can execute plan/apply from docs without path confusion

---

## Validation Gate (Phase 1 Exit)

Run and record outputs:

- [ ] `terraform -chdir=terraform/environments/k3s-dev init`
- [ ] `terraform -chdir=terraform/environments/k3s-dev validate`

Gate pass criteria:

- [ ] Architecture and roadmap have no contradictory tasking
- [ ] Terraform validate command succeeds

---

## Evidence Log

Use this section as implementation progresses.

| Date | Task | Change Summary | Validation Command | Result | Notes |
|---|---|---|---|---|---|
| 2026-02-16 | Tracker creation | Added Phase 1 implementation tracking doc | N/A | Complete | Initial baseline |
| 2026-02-16 | Task 1 (partial) | Added docs index and linked root/architecture/roadmap navigation | Link review | Complete | Hierarchy v1 established |
| 2026-02-17 | Task 1 | Completed cross-link and ownership-boundary validation across root/docs/contract/roadmap docs | `grep -RIn "docs/README.md\|EM-Infra-Talos-Proxmox-Architecture.md\|infra-roadmap-single-host-k3s-dev.md" README.md docs` and `grep -RIn "Terraform.*\(OS\|node state\|kubernetes\)" README.md docs` | Complete | Canonical navigation and ownership wording verified |
| 2026-02-17 | Task 2 | Confirmed canonical inventory intent files and role model for dev topology | `test -f inventory/dev/cluster.yaml && test -f inventory/dev/nodes.yaml`, `grep -n "control-plane\|worker\|gpu" inventory/dev/nodes.yaml`, `python3 scripts/validate_inventory.py` | Complete | Inventory contract validated |
| 2026-02-17 | Task 3 | Reconciled Terraform core constraint strategy by adding `required_version = ">= 1.3.0"` to `k3s-dev` providers config | `terraform -chdir=terraform/environments/k3s-dev init -input=false && terraform -chdir=terraform/environments/k3s-dev validate` | Complete | Init and validate both succeeded |
| 2026-02-17 | Task 4 | Updated Terraform READMEs to align Talos ownership wording, repository-real command paths, and MVP local-state guardrails | `grep -n "VM lifecycle\|Talos\|ownership" terraform/README.md terraform/environments/k3s-dev/README.md` | Complete | Boundary language and command path coverage verified |
| 2026-02-17 | Task 4 validation | Confirmed Terraform environment remains valid after documentation updates | `terraform -chdir=terraform/environments/k3s-dev validate` | Complete | `Success! The configuration is valid.` |
| 2026-02-17 | Phase 1 gate | Re-ran gate commands for closeout evidence | `terraform -chdir=terraform/environments/k3s-dev init -input=false && terraform -chdir=terraform/environments/k3s-dev validate` | Complete | Gate commands successful |

---

## Decisions & Open Questions

### Decisions

- Architecture document remains canonical for conflicts.
- Terraform manages VM lifecycle only — it creates and configures virtual machines and host-level resources; Talos is solely responsible for node OS configuration and runtime state.

- Canonical inventory location: `inventory/dev/` (decided 2026-02-17).
- Inventory node role naming: kebab-case (`control-plane`, `worker`, `gpu-worker`).

### Open questions

- [ ] Whether `schema.json` should validate inventory YAML directly or generated intermediate JSON
- [ ] Final provider version pin baseline to enforce across root + environment files

---

## Phase 1 Completion Checklist

- [x] Task 1 complete
- [x] Task 2 complete
- [x] Task 3 complete
- [x] Task 4 complete
- [x] Validation gate passed
- [x] Evidence log updated with command output summaries
