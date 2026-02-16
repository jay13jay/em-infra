# EM-Infra Documentation Index

This is the canonical entrypoint for repository documentation.

Use this page first, then follow links by intent (architecture, planning, implementation, onboarding).

---

## Start Here

- Architecture contract: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](./contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- MVP roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](./planning/infra-roadmap-single-host-k3s-dev.md)
- Active implementation tracker: [docs/implementation/phase-1-implementation-tracker.md](./implementation/phase-1-implementation-tracker.md)

---

## By Audience

### New contributor

- Onboarding checklist: [docs/guides/onboarding.md](./guides/onboarding.md)
- Windows/WSL guidance: [docs/guides/windows-dev.md](./guides/windows-dev.md)

### Infrastructure implementation

- Architecture decisions and boundaries: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](./contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- Delivery sequencing and gates: [docs/planning/infra-roadmap-single-host-k3s-dev.md](./planning/infra-roadmap-single-host-k3s-dev.md)
- Current execution checklist: [docs/implementation/phase-1-implementation-tracker.md](./implementation/phase-1-implementation-tracker.md)
- Task document template: [docs/implementation/templates/task-doc-template.md](./implementation/templates/task-doc-template.md)

---

## AI Assistant Workflow

Use this sequence for implementation work to keep context focused and reproducible.

1. Normalize canonical docs for the session:
   - architecture: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](./contracts/EM-Infra-Talos-Proxmox-Architecture.md)
   - roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](./planning/infra-roadmap-single-host-k3s-dev.md)
   - active tracker: [docs/implementation/phase-1-implementation-tracker.md](./implementation/phase-1-implementation-tracker.md)
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
