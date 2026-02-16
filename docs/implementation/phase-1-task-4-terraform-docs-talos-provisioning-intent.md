# Phase 1 Task 4 — Update Terraform Documentation for Talos Provisioning Intent

---

## Metadata

- Task ID: P1-T4
- Phase: Phase 1 — Foundations & Contract Alignment
- Title: Update Terraform documentation for Talos provisioning intent
- Owner: Solo developer + AI assistants
- Status: Not started
- Last Updated: 2026-02-16

---

## Navigation

- Docs index: [docs/README.md](../README.md)
- Architecture contract: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- Roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](../planning/infra-roadmap-single-host-k3s-dev.md)
- Phase tracker: [docs/implementation/phase-1-implementation-tracker.md](./phase-1-implementation-tracker.md)

---

## Objective

Align Terraform documentation with architecture boundaries so operators understand Terraform handles VM lifecycle only while Talos controls node OS state.

---

## Scope

### In scope

- Update root Terraform README language to Talos-native ownership boundaries
- Update `k3s-dev` environment README to match repository-real paths and command flow
- Document local state expectations for MVP

### Out of scope

- Changing Terraform code behavior
- Writing Talos bootstrap implementation details

---

## Inputs & Dependencies

- Required docs:
  - [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
  - [docs/planning/infra-roadmap-single-host-k3s-dev.md](../planning/infra-roadmap-single-host-k3s-dev.md)
- Required files:
  - [terraform/README.md](../../terraform/README.md)
  - [terraform/environments/k3s-dev/README.md](../../terraform/environments/k3s-dev/README.md)
- Required tools/commands:
  - `grep`
- Upstream tasks that must be complete first:
  - P1-T3 recommended (to keep documented constraints in sync)

---

## Target Files

- [ ] terraform/README.md
- [ ] terraform/environments/k3s-dev/README.md

---

## Implementation Steps (Atomic)

1. Review both README files for ownership language and path accuracy.
2. Update language to explicitly state Terraform manages VM lifecycle only.
3. Add/adjust command examples with repository-real paths.
4. Document MVP local state expectations and guardrails.
5. Validate docs by running command examples where practical.

---

## Validation

### Commands

- `grep -n "VM lifecycle\|Talos\|ownership" terraform/README.md terraform/environments/k3s-dev/README.md`
- `terraform -chdir=terraform/environments/k3s-dev validate`

### Expected results

- README language matches architecture ownership model.
- Command examples are executable without path confusion.

---

## Acceptance Criteria

- [ ] Root Terraform README reflects Talos-native ownership boundary
- [ ] `k3s-dev` README contains accurate command paths
- [ ] Local-state expectations are documented for MVP
- [ ] No architecture-boundary conflicts introduced

---

## Risks & Mitigations

- Risk: Documentation drifts from actual command paths.
  - Mitigation: Validate examples directly from repository root.
- Risk: Ambiguous ownership wording reappears in future edits.
  - Mitigation: Add explicit boundary statement in both README files.

---

## Execution Log

| Date | Step | Change | Validation | Result | Notes |
|---|---|---|---|---|---|
| 2026-02-16 | Baseline | Task doc created for Terraform docs alignment | N/A | Complete | Awaiting implementation |

---

## Handoff Notes

- Follow-up task(s): Phase 1 validation gate
- Open questions: None blocking
- What to attach in next AI context window:
  - [docs/implementation/phase-1-task-4-terraform-docs-talos-provisioning-intent.md](./phase-1-task-4-terraform-docs-talos-provisioning-intent.md)
  - [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
  - [terraform/README.md](../../terraform/README.md)
  - [terraform/environments/k3s-dev/README.md](../../terraform/environments/k3s-dev/README.md)
