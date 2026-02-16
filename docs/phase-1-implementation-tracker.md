# EM-Infra Phase 1 Implementation Tracker — Foundations & Contract Alignment

**Owner:** Solo developer + AI assistants  
**Phase Window:** Days 1-7 (MVP roadmap)  
**Status:** Ready to execute  
**Last Updated:** 2026-02-16

---

## Navigation

- Canonical architecture contract: [docs/EM-Infra-Talos-Proxmox-Architecture.md](./EM-Infra-Talos-Proxmox-Architecture.md)
- MVP roadmap: [docs/infra-roadmap-single-host-k3s-dev.md](./infra-roadmap-single-host-k3s-dev.md)

---

## Phase 1 Objective

Align repository docs and baseline automation contracts to the Talos-first architecture so implementation can proceed without ownership ambiguity.

If any task below conflicts with the architecture document, [docs/EM-Infra-Talos-Proxmox-Architecture.md](./EM-Infra-Talos-Proxmox-Architecture.md) is canonical.

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

## 1) Docs & architecture cross-link alignment

**Goal:** Ensure operator path is linear and no docs contradict ownership boundaries.

**Planned changes**

- [ ] Add/verify cross-links in root and infra docs
- [ ] Establish canonical docs index/hierarchy entrypoint (`docs/README.md`)
- [ ] Remove/flag any wording that implies Terraform configures node OS
- [ ] Ensure all phase references align to Talos workflow naming

**Primary files**

- `README.md`
- `docs/infra-roadmap-single-host-k3s-dev.md`
- `docs/EM-Infra-Talos-Proxmox-Architecture.md`

**Done when**

- [ ] No contradictory ownership language remains
- [ ] Navigation path from root README to architecture + roadmap is explicit
- [ ] Docs index exists and is linked by major architecture/planning docs

---

## 2) Define initial dev inventory intent files

**Goal:** Establish canonical inventory inputs for Talos config generation.

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

---

## Decisions & Open Questions

### Decisions

- Architecture document remains canonical for conflicts.
- Terraform owns VM lifecycle only; Talos owns node OS state.

### Open questions

- [ ] Final canonical location for inventory intent (`inventory/dev/` vs existing `ansible/inventory/` structure)
- [ ] Whether `schema.json` should validate inventory YAML directly or generated intermediate JSON
- [ ] Final provider version pin baseline to enforce across root + environment files

---

## Phase 1 Completion Checklist

- [ ] Task 1 complete
- [ ] Task 2 complete
- [ ] Task 3 complete
- [ ] Task 4 complete
- [ ] Validation gate passed
- [ ] Evidence log updated with command output summaries
