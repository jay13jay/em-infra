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
- P2-T6: [docs/implementation/phase-2/phase-2-task-6-proxmox-ansible-integration.md](./phase-2-task-6-proxmox-ansible-integration.md)

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

- [x] Define required outputs (control-plane endpoints, node IP map, VM IDs as needed)
- [x] Ensure output names are stable and documented
- [x] Verify outputs are available after apply

---

## 4) Local-state operations

**Goal:** Make state handling safe for a solo local workflow.

- [x] Document state file location and handling rules
- [x] Define backup cadence and command examples
- [x] Define restore procedure and drift precautions

---

## 5) Idempotency verification

**Goal:** Prove no-op reruns are clean when config is unchanged.

- [x] Execute `init/plan/apply/plan` in order with evidence
- [x] Verify second plan is no-op (or explain expected benign diffs)
- [x] Capture reproducible command transcript summary

---

## 6) Proxmox-ansible integration

**Goal:** Automate Proxmox host prep with proxmox-ansible so Talos templates and Terraform can run without manual ISO uploads.

- [x] Document YAML inventory + host_vars mapping for proxmox-ansible
- [x] Run proxmox-ansible full stack and capture reports
- [x] Confirm Talos ISO exists at `local:iso/<talos.iso>` and Talos template pipeline succeeds
- [x] Terraform `plan` unblocked with prepared template names and provider inputs

---

## Validation Gate (Phase 2 Exit)

Run and record outputs:

- [x] `terraform -chdir=terraform/environments/k3s-dev init -input=false`
- [x] `terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars`
- [x] `terraform -chdir=terraform/environments/k3s-dev apply -var-file=terraform.tfvars`
- [x] `terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars`

Gate pass criteria:

- [x] `terraform plan` succeeds from clean clone + tfvars
- [x] `terraform apply` creates expected VM topology
- [x] second `terraform plan` reports no unintended drift

---

## Evidence Log

| Date | Task | Change Summary | Validation Command | Result | Notes |
|---|---|---|---|---|---|
| 2026-02-17 | Tracker creation | Added Phase 2 tracker and task breakdown | N/A | Complete | Phase kickoff |
| 2026-02-17 | P2-T1 | Documented minimum Terraform input contract in `terraform.tfvars.example` and `k3s-dev` README, including explicit worker/GPU topology controls | `terraform -chdir=terraform/environments/k3s-dev init -input=false && terraform -chdir=terraform/environments/k3s-dev validate` | Complete | Validation succeeded after docs update |
| 2026-02-17 | P2-T2 | Hardened Terraform variable validation in `k3s-dev` for required inputs, CIDRs, PCI BDF format, and operator-facing error messages | `terraform -chdir=terraform/environments/k3s-dev validate` | Complete | Validation succeeded |
| 2026-02-17 | P2-T3 | Implemented stable `talos_*` output contract in `k3s-dev/outputs.tf`, retained legacy outputs as deprecated compatibility, and documented contract retrieval in `k3s-dev` README | `terraform -chdir=terraform/environments/k3s-dev validate && terraform -chdir=terraform/environments/k3s-dev output -json` | Complete | Config validates; new outputs will appear in state after next apply |
| 2026-02-17 | P2-T6 | Ran proxmox-ansible full stack (custom Dockerfile) against vmhost; fetched Talos ISO to local:iso; added autoinstall support to template playbook; finalized VMID 9000 to template talos-v1.12.4-base on tank | proxmox-ansible play, prepare-template (autoinstall + finalize) | Complete | Template ready; moved to Terraform validation |
| 2026-02-17 | P2-T6 | Terraform plan succeeded using template talos-v1.12.4-base via containerized terraform:1.14.5 with env tfvars | `docker run --rm -v "$PWD:/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 plan -var-file=terraform.tfvars` | Complete | Plan shows 2 VMs (control + worker) to create; outputs populated after apply |
| 2026-02-17 | P2-T6 | Terraform apply attempt failed: Proxmox missing template `talos-v1.12.4-base` | `docker run --rm -v "$PWD:/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 apply -var-file=terraform.tfvars -auto-approve` | Failed | Verify template exists on vmhost (VMID 9000) or update tfvars template name, then re-run apply |
| 2026-02-17 | P2-T6 | Root cause: `terraform@pve` user/token had zero Proxmox ACLs — token could not enumerate any VMs via `/cluster/resources`. Granted `PVEAdmin` at `/`, `PVEDatastoreAdmin` at `/storage`, `PVESysAdmin` at `/nodes/vmhost` to user and token via Proxmox API. Removed PAM creds from tfvars (token-only auth). Apply succeeded: 2 VMs created (k3s-dev-control-1 VMID 101, k3s-dev-worker-1 VMID 102). IPs empty at apply time — expected, Talos template lacks qemu-guest-agent compatible with provider IP detection. | `MSYS2_ARG_CONV_EXCL='*' docker run --rm -v "$PWD:/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 apply -var-file=terraform.tfvars -auto-approve` | Complete | Apply complete; 2 resources added |
| 2026-02-17 | Arch Review | Conducted comprehensive architectural alignment review; identified critical gap: k3s-dev environment using vm_ubuntu22 module (cloud-init/qemu-guest-agent) incompatible with Talos architecture contract | Manual review of changes vs architecture doc | Issues found | CRITICAL: Module mismatch blocks Talos integration |
| 2026-02-17 | Module Creation | Created terraform/modules/proxmox-talos-vm module per architecture spec (lines 406-413); implements Talos-native provisioning without cloud-init or guest-agent assumptions; includes GPU passthrough support | Module file creation | Complete | New module ready for integration into environments |
| 2026-02-17 | .gitignore Fix | Fixed .gitignore to allow inventory YAML commits (single-source-of-truth principle); now excludes only secrets (*.sops.yaml) instead of entire ansible/inventory/* directory | .gitignore update | Complete | Inventory versioning restored |
| 2026-02-17 | P2-T4 | Documented local-state operations in Terraform root and `k3s-dev` READMEs, including canonical state location, backup cadence, restore routine, and accidental-loss handling | `MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W):/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 init -input=false && MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W):/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 validate` | Complete | Containerized validate used because local Terraform 1.12.2 does not satisfy required_version |
| 2026-02-17 | P2-T5 | Executed full idempotency sequence (`init/plan/apply/plan`), observed recurring false drift on `disk.format` and `startup_shutdown`, then remediated by explicitly setting provider defaults in `modules/vm_ubuntu22` and `modules/gpu_worker` | `MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W):/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 init -input=false`; `... plan -var-file=terraform.tfvars`; `... apply -var-file=terraform.tfvars -auto-approve`; `... validate`; `... plan -var-file=terraform.tfvars` | Complete | Final plan now reports `No changes. Your infrastructure matches the configuration.` |
| 2026-02-17 | Module Audit + Migration | Audited in-use Terraform module sources and confirmed `k3s-dev` still referenced `vm_ubuntu22`/`gpu_worker`; migrated control plane, workers, and GPU workers to `proxmox-talos-vm` to remove Talos-incompatible cloud-init/qemu-guest-agent assumptions and refresh wait behavior tied to guest IP discovery | `MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W):/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 init -input=false`; `... validate`; `... plan -refresh=false -var-file=terraform.tfvars` | Complete | Plan succeeds; existing VMs show in-place config convergence from cloud-init settings to Talos-native settings |
| 2026-02-18 | Phase 2 closeout verification | Re-ran gate sequence after Talos module migration (`init/validate/plan/apply/plan`) using corrected container working directory; pinned Talos module defaults (`disk.format`, `startup_shutdown`) and ignored `agent` drift to avoid non-actionable shutdown churn on existing VMs | `MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W):/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 init -input=false`; `... validate`; `... plan -var-file=terraform.tfvars`; `... apply -var-file=terraform.tfvars -auto-approve`; `... plan -var-file=terraform.tfvars` | Complete with benign provider diff | Refresh is materially faster (no Talos IP wait path). Remaining plan output is provider-computed `reboot_required` churn and qemu-guest-agent warning, with no topology or input contract drift. |

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
- [x] Task 3 complete
- [x] Task 4 complete
- [x] Task 5 complete
- [x] Task 6 complete
- [x] Validation gate passed
- [x] Evidence log updated with command output summaries
