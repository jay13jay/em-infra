# EM-Infra Documentation Index

This is the canonical entrypoint for repository documentation.

Use this page first, then follow links by intent (architecture, planning, implementation, onboarding).

---

## Start Here

- Architecture contract: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](./contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- MVP roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](./planning/infra-roadmap-single-host-k3s-dev.md)
- Active implementation tracker: [docs/implementation/phase-2/phase-2-implementation-tracker.md](./implementation/phase-2/phase-2-implementation-tracker.md)
- Phase 2 task docs:
   - [docs/implementation/phase-2/phase-2-task-1-minimum-input-contract.md](./implementation/phase-2/phase-2-task-1-minimum-input-contract.md)
   - [docs/implementation/phase-2/phase-2-task-2-variable-validation-hardening.md](./implementation/phase-2/phase-2-task-2-variable-validation-hardening.md)
   - [docs/implementation/phase-2/phase-2-task-3-output-contract-for-bootstrap.md](./implementation/phase-2/phase-2-task-3-output-contract-for-bootstrap.md)
   - [docs/implementation/phase-2/phase-2-task-4-local-state-operations.md](./implementation/phase-2/phase-2-task-4-local-state-operations.md)
   - [docs/implementation/phase-2/phase-2-task-5-idempotency-verification.md](./implementation/phase-2/phase-2-task-5-idempotency-verification.md)
- Phase 1 task docs (completed):
   - [docs/implementation/phase-1/phase-1-task-1-docs-cross-link-alignment.md](./implementation/phase-1/phase-1-task-1-docs-cross-link-alignment.md)
   - [docs/implementation/phase-1/phase-1-task-2-dev-inventory-intent-files.md](./implementation/phase-1/phase-1-task-2-dev-inventory-intent-files.md)
   - [docs/implementation/phase-1/phase-1-task-3-terraform-provider-version-reconciliation.md](./implementation/phase-1/phase-1-task-3-terraform-provider-version-reconciliation.md)
   - [docs/implementation/phase-1/phase-1-task-4-terraform-docs-talos-provisioning-intent.md](./implementation/phase-1/phase-1-task-4-terraform-docs-talos-provisioning-intent.md)

---

## Version Matrix (pinned)

| Component | Version | Notes |
| --- | --- | --- |
| Terraform | 1.14.5 (pinned `<1.15`) | Matches `terraform/providers.tf` and modules |
| Telmate/proxmox provider | 3.0.2-rc07 | Pinned in provider blocks and locks |
| Talos | v1.12.4 | Inventory, templates, docs aligned |
| ansible-core | 2.20.2 | Exact pin; requires Python >= 3.12; see ansible/requirements.txt and tools/proxmox-ansible.Dockerfile |

## By Audience

### New contributor

- Onboarding checklist: [docs/guides/onboarding.md](./guides/onboarding.md)
- Windows/WSL guidance: [docs/guides/windows-dev.md](./guides/windows-dev.md)

### Infrastructure implementation

- Architecture decisions and boundaries: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](./contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- Delivery sequencing and gates: [docs/planning/infra-roadmap-single-host-k3s-dev.md](./planning/infra-roadmap-single-host-k3s-dev.md)
- Current execution checklist: [docs/implementation/phase-2/phase-2-implementation-tracker.md](./implementation/phase-2/phase-2-implementation-tracker.md)
- Task document template: [docs/implementation/templates/task-doc-template.md](./implementation/templates/task-doc-template.md)

---

## AI Assistant Workflow

Use this sequence for implementation work to keep context focused and reproducible.

1. Normalize canonical docs for the session:
   - architecture: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](./contracts/EM-Infra-Talos-Proxmox-Architecture.md)
   - roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](./planning/infra-roadmap-single-host-k3s-dev.md)
   - active tracker: [docs/implementation/phase-2/phase-2-implementation-tracker.md](./implementation/phase-2/phase-2-implementation-tracker.md)
2. Generate one task doc per tracker task using [docs/implementation/templates/task-doc-template.md](./implementation/templates/task-doc-template.md).
3. Attach all task docs + architecture + roadmap, then ask the agent to review for conflicts, ownership boundary violations, and sequencing gaps.
4. Apply review corrections to task docs.
5. For each task, open a fresh context and attach only:
   - task doc,
   - architecture contract,
   - roadmap (optional if task doc already includes dependencies).
6. Ask planning agent for an atomic execution plan (file targets, ordered steps, validation commands).
7. Review the plan, then run implementation in a separate context window.
8. Run validation commands and record results in:
   - task doc execution log,
   - phase tracker evidence log.
9. Repeat for the next task until phase gate criteria are satisfied.
10. Run a phase gate review against architecture + roadmap + tracker before closing the phase.

---

## Documentation Hierarchy (v1)

Apply these conventions for all new docs:

1. **Contract docs** (architecture and ownership boundaries)
   - Long-lived, canonical, low churn
   - Example: architecture contract

2. **Planning docs** (roadmaps, milestones, phase sequencing)
   - Time-bound, checkpoint-driven
   - Example: MVP roadmap

3. **Execution docs** (phase trackers, change logs, verification logs)
   - Operational, updated during implementation
   - Example: phase implementation tracker

4. **Onboarding/runbook docs** (developer setup and operator actions)
   - Task-oriented, “do this now” format
   - Examples: onboarding and platform-specific setup

---

## Naming & Placement Rules

- Keep canonical docs in `docs/<category>/` with explicit names.
- Prefix phase trackers as `phase-<n>-...`.
- Keep one active tracker per phase; archive superseded trackers by renaming with `-archive-YYYY-MM-DD`.
- Every major doc must include a `Navigation` section with links to:
  - this index,
  - architecture contract,
  - active roadmap.

---

## Maintenance Cadence

- Update this index whenever a new roadmap, tracker, or runbook is added.
- During weekly closeout, prune stale links and verify all doc paths resolve.
