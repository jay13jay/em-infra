# Phase 2 Task 4 — Local Terraform State Operations (Solo Dev)

## Metadata

- Task ID: P2-T4
- Phase: Phase 2 (Days 8-14)
- Title: Define local-state backup and restore rules
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

Publish a practical, low-friction local-state routine (location, backup cadence, restore steps) that reduces accidental drift and recovery time in solo workflows.

---

## Scope

### In scope

- State file location conventions for `k3s-dev`
- Backup command examples and cadence guidance
- Restore sequence and safety checks before apply

### Out of scope

- Remote backend migration and state locking (post-MVP)
- Team concurrency workflows

---

## Inputs & Dependencies

- Required docs: roadmap Phase 2 local-state requirements
- Required files:
  - `terraform/README.md`
  - `terraform/environments/k3s-dev/README.md`
  - `.gitignore` rules for state artifacts (verify only)
- Required tools/commands:
  - `terraform state list` (when state exists)
- Upstream tasks that must be complete first:
  - None (can run in parallel with P2-T1/P2-T2)

---

## Target Files

- [ ] `terraform/README.md`
- [ ] `terraform/environments/k3s-dev/README.md`

---

## Implementation Steps (Atomic)

1. Define canonical local state path and non-commit rules.
2. Add backup cadence and command snippets (timestamped copies).
3. Add restore routine and pre-apply sanity checks.
4. Add concise “what to do after accidental loss” section.

---

## Validation

### Commands

- `terraform -chdir=terraform/environments/k3s-dev validate`
- `test -f terraform/environments/k3s-dev/terraform.tfstate || true`

### Expected results

- Documentation clearly specifies where state lives and how to back it up.
- Restore steps are linear and executable.

---

## Acceptance Criteria

- [ ] Local state location, backup, and restore are documented end-to-end.
- [ ] Guidance explicitly states that state artifacts are not committed.
- [ ] No architecture-boundary conflicts introduced.

---

## Risks & Mitigations

- Risk: Operators skip backups during rapid iteration.
  - Mitigation: Add lightweight pre-apply checklist and optional helper command snippets.

---

## Execution Log

| Date | Step | Change | Validation | Result | Notes |
|---|---|---|---|---|---|
| 2026-02-17 | Task doc creation | Defined P2-T4 local-state operations plan | N/A | Complete | Ready for execution |

---

## Handoff Notes

- Follow-up task(s): P2-T5 final idempotency proof
- Open questions: Should backup cadence be per-apply or end-of-day minimum?
- What to attach in next AI context window: this task doc + Terraform READMEs + `.gitignore`
