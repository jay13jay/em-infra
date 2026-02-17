# Phase 2 Task 1 — Minimum Terraform Input Contract

## Metadata

- Task ID: P2-T1
- Phase: Phase 2 (Days 8-14)
- Title: Confirm minimum input set for `k3s-dev`
- Owner: Solo developer + AI assistants
- Status: Complete
- Last Updated: 2026-02-17

---

## Navigation

- Docs index: [docs/README.md](../../README.md)
- Architecture contract: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- Roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](../../planning/infra-roadmap-single-host-k3s-dev.md)
- Phase tracker: [docs/implementation/phase-2/phase-2-implementation-tracker.md](./phase-2-implementation-tracker.md)

---

## Objective

Define and document the smallest complete `terraform.tfvars` input set required to provision expected dev topology (control plane + workers + optional GPU workers) without hidden defaults.

---

## Scope

### In scope

- `terraform/environments/k3s-dev/terraform.tfvars.example` completeness review
- Required vs optional variable classification
- Explicit GPU worker PCI BDF list input expectations

### Out of scope

- Runtime Talos bootstrap behavior
- Proxmox host BIOS/PCI prerequisite validation

---

## Inputs & Dependencies

- Required docs: architecture contract, roadmap, Terraform READMEs
- Required files:
  - `terraform/environments/k3s-dev/variables.tf`
  - `terraform/environments/k3s-dev/terraform.tfvars.example`
  - `terraform/modules/*/variables.tf` (as needed)
- Required tools/commands:
  - `terraform -chdir=terraform/environments/k3s-dev validate`
- Upstream tasks that must be complete first:
  - Phase 1 complete (done)

---

## Target Files

- [x] `terraform/environments/k3s-dev/terraform.tfvars.example`
- [x] `terraform/environments/k3s-dev/README.md`

---

## Implementation Steps (Atomic)

1. Enumerate all environment variables and classify required/optional for MVP.
2. Ensure tfvars example covers control plane sizing/count, worker count, and GPU worker PCI BDF list fields.
3. Add short notes explaining each required field and acceptable value shape.
4. Validate the example against current variable schema using `terraform validate`.

---

## Validation

### Commands

- `terraform -chdir=terraform/environments/k3s-dev init -input=false`
- `terraform -chdir=terraform/environments/k3s-dev validate`

### Expected results

- Example file contains all required variables for baseline topology.
- Validation passes with no variable-schema mismatch errors.

---

## Acceptance Criteria

- [x] Required input set is documented in one place and matches current code.
- [x] `terraform.tfvars.example` includes worker and GPU PCI BDF examples.
- [x] No architecture-boundary conflicts introduced.

---

## Risks & Mitigations

- Risk: Drift between docs and variable definitions.
  - Mitigation: Derive final field list directly from `variables.tf` and module callsites.

---

## Execution Log

| Date | Step | Change | Validation | Result | Notes |
|---|---|---|---|---|---|
| 2026-02-17 | Task doc creation | Defined P2-T1 scope and checklist | N/A | Complete | Ready for execution |
| 2026-02-17 | Minimum input contract | Updated tfvars example and README with explicit required input set and topology controls (`worker_count`, `gpu_worker_pci_bdfs`) | `terraform -chdir=terraform/environments/k3s-dev init -input=false && terraform -chdir=terraform/environments/k3s-dev validate` | Complete | Validate passed after documentation updates |

---

## Handoff Notes

- Follow-up task(s): P2-T2 variable validation hardening
- Open questions: Should zero GPU workers require empty list or null?
- What to attach in next AI context window: this task doc + `variables.tf` + tfvars example
