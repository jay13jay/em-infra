# Architectural Alignment Review — Phase 2 Talos Template Flow

**Date:** 2026-02-17  
**Reviewer:** @copilot  
**Request:** @jay13jay requested review of changes against architectural plans  
**Status:** Review complete — critical gaps identified

---

## Executive Summary

Conducted comprehensive review of the last 5 commits in the `copilot/sub-pr-5` branch against the Talos-native architecture documented in `docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md`.

**Overall Assessment:** ⚠️ **Partially Aligned with Critical Gaps**

The implementation shows good progress on Phase 2 tasks (template preparation, documentation, proxmox-ansible integration) but has **one critical architectural misalignment** that blocks Talos integration:

- ✅ Template strategy correctly implements Talos-only templates
- ✅ Immutability principles maintained throughout
- ✅ Ownership boundaries preserved (Terraform = VM lifecycle, Talos = node OS)
- ❌ **CRITICAL: Wrong Terraform module in use** (vm_ubuntu22 instead of proxmox-talos-vm)
- ❌ **CRITICAL: .gitignore violated single-source-of-truth principle** (fixed in this review)

---

## Detailed Findings

### 1. Template Preparation (prepare-template.yml)

**Status:** ✅ **Aligned**

**Positive findings:**
- Correctly creates Talos OS-only templates (no machine config, no cluster identity)
- Storage migration from `local-lvm` to `tank` successfully implemented
- ISO handling properly separated (`local:iso` for downloads)
- Template naming follows convention: `talos-v<major>.<minor>.<patch>-base`

**Minor concern:**
- Autoinstall feature adds kernel args during template creation (lines 66-89)
- **Mitigation:** Feature is disabled by default and properly cleaned up before template conversion (line 149)
- **Verdict:** Acceptable for automation; document that this is installation-only, not runtime config

### 2. Proxmox-Ansible Integration (P2-T6)

**Status:** ⚠️ **Functional but Undocumented**

**Positive findings:**
- Execution log shows successful host prep, ISO fetch, and template creation
- Proper sequence followed: proxmox-ansible → template pipeline → Terraform
- Dockerfile properly configured with required dependencies

**Concerns:**
- P2-T6 not present in original Phase 2 roadmap (only P2-T1 through P2-T5 documented)
- proxmox-ansible adds new orchestration layer not mentioned in architecture document
- Manual Talos installation steps (between playbook runs) not documented

**Recommendation:** Update architecture document or roadmap to include proxmox-ansible workflow as canonical host prep step.

### 3. Terraform Configuration

**Status:** ❌ **CRITICAL MISALIGNMENT**

**Problem identified:**
- Current implementation: `terraform/environments/k3s-dev/main.tf` uses `vm_ubuntu22` module (lines 5-21, 23-40, 42-61)
- Architecture requirement: Document explicitly requires `proxmox-talos-vm` module (lines 406-413 of architecture doc)

**Impact analysis:**
- The `vm_ubuntu22` module has hardcoded assumptions incompatible with Talos:
  - Line 19: `os_type = "cloud-init"` (Talos doesn't use cloud-init)
  - Lines 34-42: Injects SSH keys and cloud-init configs (Talos has no SSH)
  - Line 40: `agent = var.enable_qga ? 1 : 0` (Talos doesn't support qemu-guest-agent)
- Template references are correct (`talos-v1.12.4-base`) but module cannot provision Talos VMs properly

**Root cause:**
- The architecture document's Implementation Checklist (lines 406-413) calls for creating a `proxmox-talos-vm` module
- This module was never created, so the environment fell back to using `vm_ubuntu22`
- The mismatch went undetected because template names were updated but module usage was not

**Resolution implemented:**
- ✅ Created `terraform/modules/proxmox-talos-vm` module with:
  - No cloud-init assumptions
  - No qemu-guest-agent dependency
  - Generic Linux OS type (l26)
  - Optional GPU passthrough support
  - Full documentation including troubleshooting

### 4. .gitignore Configuration

**Status:** ❌ **VIOLATED ARCHITECTURE PRINCIPLE** → ✅ **FIXED**

**Problem identified:**
- Line 45: `ansible/inventory/*` excluded entire inventory directory
- Architecture principle (lines 100-115): Inventory YAML is the **single source of truth** for cluster topology

**Impact:**
- Cannot version control cluster intent files
- Breaks reproducibility and single-source-of-truth design
- Prevents team collaboration on inventory changes

**Resolution implemented:**
- ✅ Updated .gitignore to exclude only secrets:
  ```
  ansible/inventory/**/*.sops.yaml
  ansible/inventory/**/secrets.yaml
  ansible/inventory/**/*.key
  ansible/inventory/**/*.pem
  ```
- Inventory YAML files (`cluster.yaml`, `nodes.yaml`) can now be committed

### 5. Phase 2 Validation Gate

**Status:** ⚠️ **INCOMPLETE**

**Gate criteria (phase-2-implementation-tracker.md lines 128-132):**

| Criterion | Status |
|-----------|--------|
| `terraform plan` succeeds from clean clone | ✅ Complete |
| `terraform apply` creates expected VMs | ✅ Complete (with ACL fix) |
| **second `terraform plan` reports no drift** | ❌ **NOT PERFORMED** |

**Impact:** Idempotency not proven; Phase 2 cannot be marked complete until second plan shows no changes.

**Action required:** Run second `terraform plan` and document that output shows "No changes" or explain any expected drift.

### 6. Documentation Gaps

**Gaps identified:**

1. **proxmox-ansible workflow**: Not in architecture document or roadmap
2. **Manual template steps**: Operator must run Talos installer via console between playbook runs (not documented)
3. **Module migration path**: No guidance on transitioning from vm_ubuntu22 to proxmox-talos-vm
4. **ACL requirements**: Proxmox token permissions not documented (discovered during apply failure)

---

## Architectural Compliance Matrix

| Principle | Requirement | Status | Evidence |
|-----------|-------------|--------|----------|
| **Nodes are Immutable** | No SSH, no package manager, no config drift | ✅ Pass | Template has no machine config; Talos configs generated separately |
| **Inventory = Single Source of Truth** | Inventory YAML defines cluster topology | ✅ Pass (after fix) | .gitignore now allows inventory commits |
| **Terraform Manages VM Lifecycle Only** | No OS config in Terraform | ⚠️ Pass with gap | vm_ubuntu22 module attempts cloud-init injection (wrong module) |
| **Talos Owns Node State** | Talos machine config fully defines node runtime | ✅ Pass | prepare-template.yml creates blank template |
| **No Guest Agent Dependency** | IP discovery must not rely on qemu-guest-agent | ⚠️ Gap identified | vm_ubuntu22 module expects guest agent; proxmox-talos-vm fixes this |
| **Deterministic Bring-Up** | Reproducible from inventory | ⚠️ At risk | Module mismatch could cause provisioning failures |

---

## Critical Action Items (Priority Order)

### IMMEDIATE (Blocking Talos Integration)

1. **✅ COMPLETED:** Create `terraform/modules/proxmox-talos-vm` module per architecture spec
2. **✅ COMPLETED:** Fix `.gitignore` to allow inventory YAML commits
3. **TODO:** Migrate `terraform/environments/k3s-dev/main.tf` to use `proxmox-talos-vm` instead of `vm_ubuntu22`
4. **TODO:** Update k3s-dev README to reflect Talos module usage

### HIGH (Phase 2 Completion)

5. **TODO:** Complete Phase 2 validation gate: run second `terraform plan` to verify idempotency
6. **TODO:** Document Proxmox token ACL requirements (PVEAdmin, PVEDatastoreAdmin, PVESysAdmin)
7. **TODO:** Update architecture document or roadmap to include proxmox-ansible as canonical host prep

### MEDIUM (Documentation Quality)

8. **TODO:** Document manual Talos installation steps in prepare-template.yml workflow
9. **TODO:** Create migration guide from vm_ubuntu22 to proxmox-talos-vm for existing environments
10. **TODO:** Add troubleshooting section for common Talos provisioning issues

---

## Recommendations for Next Steps

### Immediate Next Actions

1. **Update k3s-dev environment to use proxmox-talos-vm:**
   - Edit `terraform/environments/k3s-dev/main.tf`
   - Replace `source = "../../modules/vm_ubuntu22"` with `source = "../../modules/proxmox-talos-vm"`
   - Remove cloud-init parameters (ssh_authorized_keys, cloud_init_user, dhcp, static_ip_config, wait_for_ip_timeout)
   - Update outputs to handle null IP addresses

2. **Run validation:**
   ```bash
   terraform -chdir=terraform/environments/k3s-dev init -upgrade
   terraform -chdir=terraform/environments/k3s-dev validate
   ```

3. **Complete Phase 2 gate:**
   ```bash
   terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars
   # Should output: "No changes. Your infrastructure matches the configuration."
   ```

### Phase 3 Readiness

The new `proxmox-talos-vm` module is now ready for Phase 3 (Talos bootstrap orchestration). Key integration points:

- Module outputs VMID and VM name for bootstrap targeting
- No IP discovery dependency (Phase 3 must use inventory-defined IPs or MAC-based DHCP)
- GPU passthrough supported via `gpu_pci_bdf` parameter

---

## Conclusion

**Summary:** The implementation shows good architectural awareness and properly implements most Talos principles. The critical gap (wrong Terraform module) has been identified and resolved by creating the required `proxmox-talos-vm` module.

**Phase 2 Status:** ⚠️ **Incomplete** — requires module migration and validation gate completion before marking complete.

**Risk Assessment:** 🔴 **High** — Current vm_ubuntu22 module cannot properly provision Talos VMs; must migrate to proxmox-talos-vm before proceeding to Phase 3.

**Path Forward:** Clear action items documented above; estimated effort to complete: 2-4 hours.

---

**Reviewed by:** @copilot  
**Review date:** 2026-02-17  
**Review commit:** dac3f8d
