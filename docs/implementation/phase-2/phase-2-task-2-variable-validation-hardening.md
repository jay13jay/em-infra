# Phase 2 Task 2 — Terraform Variable Validation Hardening

## Metadata

- Task ID: P2-T2
- Phase: Phase 2 (Days 8-14)
- Title: Harden variable validation for safe reruns
- Owner: Solo developer + AI assistants
- Status: Not started
- Last Updated: 2026-02-17

---

## Navigation

- Docs index: [docs/README.md](../../README.md)
- Architecture contract: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- Roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](../../planning/infra-roadmap-single-host-k3s-dev.md)
- Phase tracker: [docs/implementation/phase-2/phase-2-implementation-tracker.md](./phase-2-implementation-tracker.md)

---

## Objective

Improve Terraform input validation so invalid CIDRs, template references, IDs, and topology values fail early with clear messages before provisioning starts.

---

## Scope

### In scope

- Validation blocks in environment/module variable definitions
- Error message clarity and actionability
- Consistency checks between root and environment variable contracts

### Out of scope

- Runtime checks requiring live Proxmox API calls
- Non-Terraform schema validation tooling changes

---

## Inputs & Dependencies

- Required docs: roadmap Phase 2 goals
- Required files:
  - `terraform/environments/k3s-dev/variables.tf`
  - `terraform/variables.tf` (if applicable)
  - module variable files touched by environment inputs
- Required tools/commands:
  - `terraform -chdir=terraform/environments/k3s-dev validate`
- Upstream tasks that must be complete first:
  - P2-T1 recommended first for required input clarity

---

## Target Files

- [ ] `terraform/environments/k3s-dev/variables.tf`
- [ ] `terraform/modules/**/variables.tf` (only where needed)

---

## Implementation Steps (Atomic)

1. Identify high-risk variables (CIDRs, IDs, template names, counts, lists).
2. Add or tighten validation conditions and concise error messages.
3. Confirm validation logic matches real accepted value formats.
4. Run `terraform validate` and negative-input spot checks as feasible.

---

## Validation

### Commands

- `terraform -chdir=terraform/environments/k3s-dev validate`
- `terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars`

### Expected results

- Invalid formats fail fast with understandable guidance.
- Valid baseline config plans cleanly.

---

## Acceptance Criteria

- [ ] Validation covers CIDR, template naming/reference, and required ID classes.
- [ ] Error messages describe fix path, not only failure reason.
- [ ] No architecture-boundary conflicts introduced.

---

## Risks & Mitigations

- Risk: Over-strict validation blocks valid edge cases.
  - Mitigation: Use permissive-but-safe patterns and test with existing known-good tfvars.

---

## Execution Log

| Date | Step | Change | Validation | Result | Notes |
|---|---|---|---|---|---|
| 2026-02-17 | Task doc creation | Defined P2-T2 validation hardening plan | N/A | Complete | Ready for execution |

---

## Handoff Notes

- Follow-up task(s): P2-T3 output contract
- Open questions: Which IDs are mandatory in all environments vs dev-only?
- What to attach in next AI context window: this task doc + `variables.tf` files + sample tfvars
