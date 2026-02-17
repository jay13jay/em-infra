# Phase 2 Task 3 — Terraform Output Contract for Talos Bootstrap

## Metadata

- Task ID: P2-T3
- Phase: Phase 2 (Days 8-14)
- Title: Define and verify bootstrap output contract
- Owner: Solo developer + AI assistants
- Status: In progress
- Last Updated: 2026-02-17

---

## Navigation

- Docs index: [docs/README.md](../../README.md)
- Architecture contract: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- Roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](../../planning/infra-roadmap-single-host-k3s-dev.md)
- Phase tracker: [docs/implementation/phase-2/phase-2-implementation-tracker.md](./phase-2-implementation-tracker.md)

---

## Objective

Define stable Terraform outputs required by Talos bootstrap orchestration so Phase 3 can consume machine endpoints and node metadata without ad-hoc parsing.

---

## Scope

### In scope

- Output naming and structure in `k3s-dev`
- Documentation of required consumers (Talos bootstrap playbooks/scripts)
- Verification of output availability after apply

### Out of scope

- Implementing Talos bootstrap playbooks themselves
- Non-Terraform output transport mechanisms

---

## Inputs & Dependencies

- Required docs: architecture ownership boundaries, roadmap Phase 3 dependency
- Required files:
  - `terraform/environments/k3s-dev/outputs.tf`
  - `terraform/environments/k3s-dev/README.md`
- Required tools/commands:
  - `terraform -chdir=terraform/environments/k3s-dev output`
- Upstream tasks that must be complete first:
  - P2-T1, P2-T2 preferred

---

## Target Files

- [x] `terraform/environments/k3s-dev/outputs.tf`
- [x] `terraform/environments/k3s-dev/README.md`

---

## Implementation Steps (Atomic)

1. Identify Phase 3 consumer needs (control-plane endpoint, node role/IP mappings, IDs as needed).
2. Add/normalize outputs with stable names and predictable types.
3. Document output semantics and example retrieval commands.
4. Confirm outputs render after apply.

---

## Validation

### Commands

- `terraform -chdir=terraform/environments/k3s-dev validate`
- `terraform -chdir=terraform/environments/k3s-dev output`
- `terraform -chdir=terraform/environments/k3s-dev output -json`

### Expected results

- Output set is complete for bootstrap handoff.
- Output types are machine-consumable and stable across reruns.

---

## Acceptance Criteria

- [x] Required bootstrap outputs exist and are documented.
- [x] Output names avoid ambiguous or environment-specific shortcuts.
- [x] No architecture-boundary conflicts introduced.

---

## Risks & Mitigations

- Risk: Output schema churn breaks downstream automation.
  - Mitigation: Treat output keys as contract and version changes explicitly in docs.

---

## Execution Log

| Date | Step | Change | Validation | Result | Notes |
|---|---|---|---|---|---|
| 2026-02-17 | Task doc creation | Defined P2-T3 output contract plan | N/A | Complete | Ready for execution |
| 2026-02-17 | Contract implementation | Added stable `talos_*` outputs in `k3s-dev/outputs.tf`, retained legacy outputs as deprecated compatibility, and documented retrieval semantics in `k3s-dev/README.md` | `terraform -chdir=terraform/environments/k3s-dev validate` | Complete | Validate succeeded |
| 2026-02-17 | Output availability check | Verified `terraform output` and `terraform output -json` command behavior against local state | `terraform -chdir=terraform/environments/k3s-dev output && terraform -chdir=terraform/environments/k3s-dev output -json` | Complete | Local state still reflects previous apply; run `terraform apply -var-file=terraform.tfvars` to materialize newly added `talos_*` outputs |

---

## Handoff Notes

- Follow-up task(s): P2-T5 idempotency verification after output stabilization
- Open questions: Should any diagnostics-only output fields be pruned before Phase 3 contract freeze?
- What to attach in next AI context window: this task doc + `outputs.tf` + downstream consumer notes
