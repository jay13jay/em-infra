# Phase 1 Task 1 — Docs & Architecture Cross-Link Alignment

---

## Metadata

- Task ID: P1-T1
- Phase: Phase 1 — Foundations & Contract Alignment
- Title: Docs & architecture cross-link alignment
- Owner: Solo developer + AI assistants
- Status: Complete
- Last Updated: 2026-02-17

---

## Navigation

- Docs index: [docs/README.md](../../README.md)
- Architecture contract: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- Roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](../../planning/infra-roadmap-single-host-k3s-dev.md)
- Phase tracker: [docs/implementation/phase-1/phase-1-implementation-tracker.md](./phase-1-implementation-tracker.md)

---

## Objective

Ensure operator navigation is linear from root documentation to architecture and roadmap, and remove wording that violates the Talos-first ownership boundary.

---

## Scope

### In scope

- Validate and normalize cross-links across root and infra docs
- Ensure `docs/README.md` is referenced as canonical docs entrypoint
- Remove or flag wording that implies Terraform configures node OS
- Align phase terminology to Talos workflow naming

### Out of scope

- Editing implementation logic in Terraform/Ansible modules
- Introducing new architecture decisions beyond current contract

---

## Inputs & Dependencies

- Required docs:
  - [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
  - [docs/planning/infra-roadmap-single-host-k3s-dev.md](../../planning/infra-roadmap-single-host-k3s-dev.md)
  - [docs/README.md](../../README.md)
- Required files:
  - [README.md](../../README.md)
  - [docs/planning/infra-roadmap-single-host-k3s-dev.md](../../planning/infra-roadmap-single-host-k3s-dev.md)
  - [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- Required tools/commands:
  - `grep`
- Upstream tasks that must be complete first:
  - None

---

## Target Files

- [x] README.md
- [x] docs/planning/infra-roadmap-single-host-k3s-dev.md
- [x] docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md
- [x] docs/README.md

---

## Implementation Steps (Atomic)

1. Review current root/docs navigation links and identify missing or stale links.
2. Normalize each major doc to include Navigation links to docs index, architecture, and roadmap.
3. Search for language that blurs ownership boundaries (Terraform vs Talos) and correct wording.
4. Verify phase naming consistency against roadmap terms.
5. Re-run link/path sanity checks for all edited docs.

---

## Validation

### Commands

- `grep -RIn "docs/README.md\|EM-Infra-Talos-Proxmox-Architecture.md\|infra-roadmap-single-host-k3s-dev.md" README.md docs`
- `grep -RIn "Terraform.*\(OS\|node state\|kubernetes\)" README.md docs || true`

### Expected results

- Major architecture and planning docs have explicit navigation links.
- No contradictory wording remains that assigns node OS ownership to Terraform.

---

## Acceptance Criteria

- [x] Navigation path from root README to architecture + roadmap is explicit
- [x] Canonical docs index is linked by major docs
- [x] No contradictory ownership language remains
- [x] No architecture-boundary conflicts introduced

---

## Risks & Mitigations

- Risk: Legacy wording remains in non-obvious sections.
  - Mitigation: Use targeted repository-wide `grep` for Terraform/OS ownership phrases.

---

## Execution Log

| Date | Step | Change | Validation | Result | Notes |
|---|---|---|---|---|---|
| 2026-02-16 | Baseline | Task doc created and aligned to phase tracker scope | N/A | Complete | Tracker indicates partial completion already exists |
| 2026-02-17 | Link/path audit | Verified canonical cross-links across root/docs/contract/roadmap docs | `grep -RIn "docs/README.md\|EM-Infra-Talos-Proxmox-Architecture.md\|infra-roadmap-single-host-k3s-dev.md" README.md docs` | Complete | Required navigation links present |
| 2026-02-17 | Ownership-boundary audit | Verified Terraform/Talos ownership wording consistency and no node-OS ownership conflicts | `grep -RIn "Terraform.*\(OS\|node state\|kubernetes\)" README.md docs` | Complete | Matches architecture boundary language |

---

## Handoff Notes

- Follow-up task(s): P1-T2 inventory intent files
- Open questions: None blocking
- What to attach in next AI context window:
  - [docs/implementation/phase-1/phase-1-task-1-docs-cross-link-alignment.md](./phase-1-task-1-docs-cross-link-alignment.md)
  - [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
  - [docs/planning/infra-roadmap-single-host-k3s-dev.md](../../planning/infra-roadmap-single-host-k3s-dev.md)
