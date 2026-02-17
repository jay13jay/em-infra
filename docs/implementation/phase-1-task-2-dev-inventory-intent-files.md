# Phase 1 Task 2 — Define Initial Dev Inventory Intent Files

---

## Metadata

- Task ID: P1-T2
- Phase: Phase 1 — Foundations & Contract Alignment
- Title: Define initial dev inventory intent files
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

Establish canonical inventory intent inputs that will be consumed by later Talos machine-config generation by defining `cluster.yaml` and `nodes.yaml` for single-host dev topology.

---

## Scope

### In scope

- Create `inventory/dev/cluster.yaml`
- Create `inventory/dev/nodes.yaml`
- Include minimal fields for control plane, worker, and optional GPU worker representation
- Document ownership expectation (inventory as source of truth)
- Update `schema.json` only if required for immediate validation contract
- Clarify sequencing: inventory intent is delivered in this task; Talos machine-config generation is validated in Phase 3

### Out of scope

- Implementing full Talos machineconfig generation pipeline
- Converting existing Ansible inventory flows
- Defining HA or multi-host topologies
- Producing `talos/generated/*` or `talos-machines.auto.tfvars.json` artifacts in this phase

---

## Inputs & Dependencies

- Required docs:
  - [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
  - [docs/planning/infra-roadmap-single-host-k3s-dev.md](../planning/infra-roadmap-single-host-k3s-dev.md)
  - [docs/implementation/phase-1-implementation-tracker.md](./phase-1-implementation-tracker.md)
- Required files:
  - [schema.json](../../schema.json)
- Required tools/commands:
  - `mkdir`, `test`, `grep`
- Upstream tasks that must be complete first:
  - P1-T1 recommended (for docs consistency), not strictly blocking

---

## Target Files

- [x] inventory/dev/cluster.yaml
- [x] inventory/dev/nodes.yaml
- [x] schema.json (validation contract present; no update required in this phase)

---

## Implementation Steps (Atomic)

1. Confirm canonical location decision for inventory intent (`inventory/dev/`).
2. Draft minimal `cluster.yaml` with environment, networking, and cluster identity fields.
3. Draft `nodes.yaml` with role-based entries for control plane, worker, and optional GPU worker.
4. Verify field names against architecture examples and planned generation flow.
5. Update `schema.json` only when field contract must be enforced in this phase.
6. Record ownership statement in docs/tracker notes: inventory is source of truth.

---

## Validation

### Commands

- `test -f inventory/dev/cluster.yaml && test -f inventory/dev/nodes.yaml`
- `grep -n "control-plane\|worker\|gpu" inventory/dev/nodes.yaml`
- `grep -n "source of truth\|inventory" docs/implementation/phase-1-implementation-tracker.md || true`

### Expected results

- Both inventory files exist and are syntactically valid YAML.
- Role model supports control plane + worker + optional GPU worker.
- Ownership intent is documented and unambiguous.

---

## Acceptance Criteria

- [x] `inventory/dev/cluster.yaml` exists with valid YAML syntax
- [x] `inventory/dev/nodes.yaml` exists with valid YAML syntax
- [x] Field names align with architecture examples
- [x] Model represents control plane + worker + optional GPU worker
- [x] No architecture-boundary conflicts introduced

---

## Risks & Mitigations

- Risk: Inventory structure diverges from future Talos config generator expectations.
  - Mitigation: Keep schema minimal and aligned to architecture contract terms only.
- Risk: Ambiguity between `inventory/dev/` and `ansible/inventory/` ownership.
  - Mitigation: Document canonical location decision in tracker and this task log.

---

## Execution Log

| Date | Step | Change | Validation | Result | Notes |
|---|---|---|---|---|---|
| 2026-02-16 | Baseline | Task doc created for execution planning | N/A | Complete | Awaiting implementation |
| 2026-02-17 | Inventory intent files | Confirmed canonical files exist with expected minimal dev topology fields and role model | `test -f inventory/dev/cluster.yaml && test -f inventory/dev/nodes.yaml` | Complete | Both files present |
| 2026-02-17 | Role model validation | Verified control-plane, worker, and gpu-worker role representation in `nodes.yaml` | `grep -n "control-plane\|worker\|gpu" inventory/dev/nodes.yaml` | Complete | Role coverage present |
| 2026-02-17 | Schema/basic validation | Validated inventory contract via repo validator script | `python3 scripts/validate_inventory.py` | Complete | `Validation: OK (basic checks)` |

---

## Handoff Notes

- Follow-up task(s): P1-T3 provider reconciliation
- Open questions:
  - Talos machine-config generator implementation owner and insertion point in Phase 3 execution sequence
  - Whether `schema.json` validates YAML directly or generated JSON
- What to attach in next AI context window:
  - [docs/implementation/phase-1-task-2-dev-inventory-intent-files.md](./phase-1-task-2-dev-inventory-intent-files.md)
  - [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
  - [docs/planning/infra-roadmap-single-host-k3s-dev.md](../planning/infra-roadmap-single-host-k3s-dev.md)

Dependency note: This task defines canonical inventory intent only. Talos machine-config generation and related output artifacts are validated in roadmap Phase 3 (`talos-gen-config` workflow).
