# Phase 2 Task 5 — Idempotency Verification (`plan/apply/plan`)

## Metadata

- Task ID: P2-T5
- Phase: Phase 2 (Days 8-14)
- Title: Verify no-op rerun behavior
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

Demonstrate predictable rerun behavior by executing and recording a clean `plan -> apply -> plan` cycle, then documenting any expected benign diffs.

---

## Scope

### In scope

- Baseline command sequence and expected outputs
- Evidence capture format in tracker/task docs
- Drift/no-drift interpretation rules for this environment

### Out of scope

- Root-cause remediation of unrelated provider bugs
- Multi-environment matrix testing

---

## Inputs & Dependencies

- Required docs: roadmap Phase 2 gate criteria
- Required files:
  - `docs/implementation/phase-2/phase-2-implementation-tracker.md`
  - `terraform/environments/k3s-dev/*`
- Required tools/commands:
  - `terraform init/plan/apply/plan`
- Upstream tasks that must be complete first:
  - P2-T1 through P2-T4 should be complete first

---

## Target Files

- [x] `docs/implementation/phase-2/phase-2-implementation-tracker.md`
- [x] `docs/implementation/phase-2/phase-2-task-5-idempotency-verification.md`

---

## Implementation Steps (Atomic)

1. Initialize Terraform environment from clean checkout assumptions.
2. Run initial `plan` and capture topology summary.
3. Run `apply` and capture resource creation summary.
4. Run second `plan` and classify output as no-op or explain expected diff.
5. Record exact command outcomes in phase evidence log.

---

## Validation

### Commands

- `terraform -chdir=terraform/environments/k3s-dev init -input=false`
- `terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars`
- `terraform -chdir=terraform/environments/k3s-dev apply -var-file=terraform.tfvars`
- `terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars`

### Expected results

- Commands execute successfully with no unexpected failures.
- Second plan is no-op or only known/accepted benign diffs.

---

## Acceptance Criteria

- [x] Full command sequence is executed and recorded.
- [x] Rerun behavior is explicitly documented for operator expectations.
- [x] No architecture-boundary conflicts introduced.

---

## Risks & Mitigations

- Risk: External Proxmox-side mutation causes drift unrelated to code.
  - Mitigation: Capture timestamped environment notes and classify drift source clearly.

---

## Execution Log

| Date | Step | Change | Validation | Result | Notes |
|---|---|---|---|---|---|
| 2026-02-17 | Task doc creation | Defined P2-T5 idempotency verification plan | N/A | Complete | Ready for execution |
| 2026-02-17 | Idempotency run | Executed `init -> plan -> apply -> plan` against `terraform/environments/k3s-dev` with containerized Terraform 1.14.5 | `MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W):/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 init -input=false`; `... plan -var-file=terraform.tfvars`; `... apply -var-file=terraform.tfvars -auto-approve`; `... plan -var-file=terraform.tfvars` | Complete with known benign diffs | Both plans reported `0 to add, 2 to change, 0 to destroy` for `disk.format` (`raw -> null`) and `startup_shutdown` defaults (`-1 -> null`) on control-plane + worker VMs; changes are recurring provider normalization noise, not topology drift |
| 2026-02-17 | Drift-remediation rerun | Added explicit `disk.format = "raw"` and explicit `startup_shutdown` defaults in VM modules, then reran validation and plan | `MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W):/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 validate`; `MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W):/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 plan -var-file=terraform.tfvars` | Complete | Plan now reports `No changes. Your infrastructure matches the configuration.`; false drift eliminated for these fields |

## Findings

- Initial rerun showed provider normalization drift on `disk.format` and `startup_shutdown` defaults.
- Explicitly setting those values in module config removed the false-positive diffs.
- Current rerun behavior is clean no-op (`No changes`) with stable VM topology and Talos output contract.

---

## Handoff Notes

- Follow-up task(s): Phase 2 gate closeout review
- Open questions: Which diffs (if any) are accepted as provider-noise for MVP?
- What to attach in next AI context window: this task doc + tracker + latest plan/apply output snippets
