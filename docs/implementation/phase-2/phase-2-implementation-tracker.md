# EM-Infra Phase 2 Implementation Tracker — Provisioning Reliability (Terraform)

**Owner:** Solo developer + AI assistants  
**Phase Window:** Days 8-14 (MVP roadmap)  
**Status:** In progress  
**Last Updated:** 2026-02-17

---

## Navigation

- Docs index: [docs/README.md](../../README.md)
- Canonical architecture contract: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../../contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- MVP roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](../../planning/infra-roadmap-single-host-k3s-dev.md)
- Previous phase tracker (complete): [docs/implementation/phase-1/phase-1-implementation-tracker.md](../phase-1/phase-1-implementation-tracker.md)

---

## Phase 2 Objective

Make Talos VM provisioning on a single Proxmox host predictable and safe to rerun by tightening Terraform inputs, validation, outputs, and local-state operations.

If any task below conflicts with the architecture document, [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../../contracts/EM-Infra-Talos-Proxmox-Architecture.md) is canonical.

---

## Scope for This Phase

### In scope

- Minimum `terraform.tfvars` input contract documentation
- Variable validation hardening for common misconfiguration classes
- Output contract for Talos bootstrap handoff
- Local-state operations and recovery routine for solo workflow
- Idempotency verification for `plan/apply/plan`

### Out of scope

- Talos bootstrap orchestration logic changes (Phase 3)
- One-command orchestrator implementation (Phase 4)
- HA/multi-host behavior

---

## Task Tracker

### Task documents

- P2-T1: [docs/implementation/phase-2/phase-2-task-1-minimum-input-contract.md](./phase-2-task-1-minimum-input-contract.md)
- P2-T2: [docs/implementation/phase-2/phase-2-task-2-variable-validation-hardening.md](./phase-2-task-2-variable-validation-hardening.md)
- P2-T3: [docs/implementation/phase-2/phase-2-task-3-output-contract-for-bootstrap.md](./phase-2-task-3-output-contract-for-bootstrap.md)
- P2-T4: [docs/implementation/phase-2/phase-2-task-4-local-state-operations.md](./phase-2-task-4-local-state-operations.md)
- P2-T5: [docs/implementation/phase-2/phase-2-task-5-idempotency-verification.md](./phase-2-task-5-idempotency-verification.md)

## 1) Minimum input contract

**Goal:** Document the smallest complete input set required to provision expected topology.

- [x] Confirm required fields in `terraform/environments/k3s-dev/terraform.tfvars.example`
- [x] Ensure control plane, worker count, and GPU PCI BDF list are explicitly covered
- [x] Align examples with current module variable names


---

## 2) Variable validation hardening

**Goal:** Fail fast on bad data before resource creation.

- [x] Add/adjust validations for CIDRs, template names, IDs, and topology counts
- [x] Keep validation messages actionable and operator-facing
- [x] Confirm no contradictory validation exists across root and environment layers


---

## 3) Output contract for Talos bootstrap

**Goal:** Provide deterministic outputs required by Phase 3 Talos orchestration.

- [ ] Define required outputs (control-plane endpoints, node IP map, VM IDs as needed)
- [ ] Ensure output names are stable and documented
- [ ] Verify outputs are available after apply

---

## 4) Local-state operations

**Goal:** Make state handling safe for a solo local workflow.

- [ ] Document state file location and handling rules
- [ ] Define backup cadence and command examples
- [ ] Define restore procedure and drift precautions

---

## 5) Idempotency verification

**Goal:** Prove no-op reruns are clean when config is unchanged.

- [ ] Execute `init/plan/apply/plan` in order with evidence
- [ ] Verify second plan is no-op (or explain expected benign diffs)
- [ ] Capture reproducible command transcript summary

---

## Validation Gate (Phase 2 Exit)

Run and record outputs:

- [ ] `terraform -chdir=terraform/environments/k3s-dev init -input=false`
- [ ] `terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars`
- [ ] `terraform -chdir=terraform/environments/k3s-dev apply -var-file=terraform.tfvars`
- [ ] `terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars`

Gate pass criteria:

- [ ] `terraform plan` succeeds from clean clone + tfvars
- [ ] `terraform apply` creates expected VM topology
- [ ] second `terraform plan` reports no unintended drift

---

## Evidence Log

| Date | Task | Change Summary | Validation Command | Result | Notes |
|---|---|---|---|---|---|
| 2026-02-17 | Tracker creation | Added Phase 2 tracker and task breakdown | N/A | Complete | Phase kickoff |
| 2026-02-17 | P2-T1 | Documented minimum Terraform input contract in `terraform.tfvars.example` and `k3s-dev` README, including explicit worker/GPU topology controls | `terraform -chdir=terraform/environments/k3s-dev init -input=false && terraform -chdir=terraform/environments/k3s-dev validate` | Complete | Validation succeeded after docs update |
| 2026-02-17 | P2-T2 | Hardened Terraform variable validation in `k3s-dev` for required inputs, CIDRs, PCI BDF format, and operator-facing error messages | `terraform -chdir=terraform/environments/k3s-dev validate` | Complete | Validation succeeded |

---

## Decisions & Open Questions

### Decisions

- Phase 2 is Terraform reliability hardening only; Talos bootstrap logic remains Phase 3 scope.
- Existing directory/file naming conventions are retained (`phase-2-*`).

### Open questions

- [ ] Whether to enforce strict semver pattern validation on Talos/Kubernetes version variables at Terraform layer vs inventory validation layer
- [ ] Whether output contract should include optional diagnostics-only fields (e.g., Proxmox node names)

---

## Phase 2 Completion Checklist

- [x] Task 1 complete
- [x] Task 2 complete
- [ ] Task 3 complete
- [ ] Task 4 complete
- [ ] Task 5 complete
- [ ] Validation gate passed
- [ ] Evidence log updated with command output summaries
