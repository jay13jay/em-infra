# Phase 1 Task 3 — Reconcile Terraform Provider Version Constraints

---

## Metadata

- Task ID: P1-T3
- Phase: Phase 1 — Foundations & Contract Alignment
- Title: Reconcile Terraform provider version constraints
- Owner: Solo developer + AI assistants
- Status: Complete
- Last Updated: 2026-02-17

---

## Navigation

- Docs index: [docs/README.md](../README.md)
- Architecture contract: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- Roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](../planning/infra-roadmap-single-host-k3s-dev.md)
- Phase tracker: [docs/implementation/phase-1-implementation-tracker.md](./phase-1-implementation-tracker.md)

---

## Objective

Eliminate provider and Terraform version drift between root and `k3s-dev` environment configuration so `init`/`validate` is deterministic.

---

## Scope

### In scope

- Compare root and environment provider blocks
- Align provider version constraints and strategy
- Align Terraform core version constraint strategy if needed
- Run and record `terraform init` and `terraform validate` for `k3s-dev`

### Out of scope

- Refactoring module internals unrelated to version constraints
- Environment expansion beyond `k3s-dev`

---

## Inputs & Dependencies

- Required docs:
  - [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
  - [docs/implementation/phase-1-implementation-tracker.md](./phase-1-implementation-tracker.md)
- Required files:
  - [terraform/providers.tf](../../terraform/providers.tf)
  - [terraform/environments/k3s-dev/providers.tf](../../terraform/environments/k3s-dev/providers.tf)
- Required tools/commands:
  - `terraform`
- Upstream tasks that must be complete first:
  - None

---

## Target Files

- [x] terraform/providers.tf
- [x] terraform/environments/k3s-dev/providers.tf

---

## Implementation Steps (Atomic)

1. Diff provider and Terraform version constraints between root and `k3s-dev`.
2. Select a single version pinning strategy compatible with current modules.
3. Update root and environment provider blocks for consistency.
4. Run `terraform -chdir=terraform/environments/k3s-dev init`.
5. Run `terraform -chdir=terraform/environments/k3s-dev validate`.
6. Record command summaries in phase tracker Evidence Log.

---

## Validation

### Commands

- `terraform -chdir=terraform/environments/k3s-dev init`
- `terraform -chdir=terraform/environments/k3s-dev validate`

### Expected results

- No conflicting provider constraints remain between root and environment.
- `terraform validate` succeeds in `k3s-dev`.

---

## Acceptance Criteria

- [x] Provider constraints are aligned across root and `k3s-dev`
- [x] Terraform version constraint strategy is consistent
- [x] `terraform -chdir=terraform/environments/k3s-dev validate` passes
- [x] No architecture-boundary conflicts introduced

---

## Risks & Mitigations

- Risk: Provider constraints that are too strict block initialization in dev.
  - Mitigation: Use compatible semantic constraints and validate immediately.
- Risk: Hidden indirect constraints in modules cause drift.
  - Mitigation: Search all Terraform provider declarations before finalizing.

---

## Execution Log

| Date | Step | Change | Validation | Result | Notes |
|---|---|---|---|---|---|
| 2026-02-16 | Baseline | Task doc created for provider reconciliation | N/A | Complete | Awaiting implementation |
| 2026-02-17 | Constraint audit | Compared provider declarations across root, `k3s-dev`, modules, and examples | Source review | Complete | No conflicting provider versions found |
| 2026-02-17 | Constraint reconciliation | Added `required_version = ">= 1.3.0"` to `terraform/environments/k3s-dev/providers.tf` | `terraform -chdir=terraform/environments/k3s-dev init -input=false` | Complete | Core-version strategy now explicit and aligned |
| 2026-02-17 | Validation | Verified environment config remains valid after reconciliation | `terraform -chdir=terraform/environments/k3s-dev validate` | Complete | `Success! The configuration is valid.` |

---

## Handoff Notes

- Follow-up task(s): P1-T4 Terraform docs update
- Open questions:
  - Final provider version baseline to enforce repo-wide
- What to attach in next AI context window:
  - [docs/implementation/phase-1-task-3-terraform-provider-version-reconciliation.md](./phase-1-task-3-terraform-provider-version-reconciliation.md)
  - [terraform/providers.tf](../../terraform/providers.tf)
  - [terraform/environments/k3s-dev/providers.tf](../../terraform/environments/k3s-dev/providers.tf)
