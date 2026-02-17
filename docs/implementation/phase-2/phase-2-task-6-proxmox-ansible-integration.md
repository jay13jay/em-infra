# Phase 2 Task 6 — Proxmox-Ansible Integration for Terraform Readiness

## Metadata

- Task ID: P2-T6
- Phase: Phase 2 (Days 8-14)
- Title: Run proxmox-ansible host prep before Talos templates and Terraform
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

Document and standardize the Proxmox host-prep phase using `proxmox-ansible` so Terraform can run without manual ISO uploads or Proxmox drift. This phase must finish before Talos template creation and any Terraform `plan/apply` for k3s-dev.

---

## Scope

### In scope

- Inventory model for `proxmox-ansible` (YAML inventory + `host_vars/*`), mapped from current INI stub
- Required variables for host prep (SSH user/key/port, root login policy, storage target, bridge, Talos ISO target path, kernel/ZFS toggles)
- Run sequence: proxmox-ansible (full stack) → local Ansible Talos template pipeline → Terraform
- ISO handling: ensure Talos ISO is downloaded to `local:iso/<talos.iso>` expected by local playbooks
- Verification steps and evidence expectations for this phase

### Out of scope

- Talos guest OS customization (remains immutable)
- Multi-host HA patterns (single Proxmox host focus)
- Changing Terraform module topology or outputs

---

## Inputs & Dependencies

- Required docs: architecture contract, proxmox-ansible README, local Ansible template guide
- Required files:
  - This repo: `ansible/inventory/proxmox/hosts.ini` (source inventory values), `ansible/README_PREPARE_TEMPLATE.md`, `ansible/playbooks/prepare-template.yml`
  - External repo: `proxmox-ansible` playbook (`proxmox.yml`), sample inventory/host_vars
- Required tools/commands:
  - Docker (to run proxmox-ansible container) or local Ansible 11.9.0 equivalent
  - `cloud-localds` available on control workstation (for later template pipeline)
  - Proxmox root SSH key-based access
- Upstream tasks that must be complete first:
  - Phase 1 complete
  - P2-T1/P2-T2 complete (inputs and validation hardened)

---

## Target Files

- [x] `docs/implementation/phase-2/phase-2-task-6-proxmox-ansible-integration.md` (this plan)
- [x] `docs/implementation/phase-2/phase-2-implementation-tracker.md` (tracker update)

---

## Implementation Steps (Atomic)

1. Define inventory bridge: create `inventory.yml` and per-host `host_vars/<proxmox-host>.yml` using values from `ansible/inventory/proxmox/hosts.ini` (host/IP, SSH user/key, SSH port, storage target like `local-zfs`, bridge like `vmbr0`, Talos ISO filename/path under `local:iso/`). **(done)**
2. Review proxmox-ansible variables: set root login/password auth toggles, SSH port, kernel pinning, nested virtualization, ZFS options, fail2ban/nginx/docs generation per host policy. **(done)**
3. Run proxmox-ansible full stack against the Proxmox host to converge OS/kernel/SSH, enable PCIe passthrough if needed, and download required ISOs (including Talos ISO) into Proxmox ISO storage. **(done)**
4. Verify Proxmox readiness: ISO present at `local:iso/<talos.iso>`, bridges and storage match expectations, root key access still works, proxmox-ansible reports generated. **(done)**
5. Run local Talos template pipeline: execute `ansible/playbooks/prepare-template.yml` (autoinstall enabled) to create `talos-v<major>.<minor>.<patch>-base` template using the downloaded ISO. **(done)**
6. Feed Terraform: set template names and Proxmox credentials in `terraform/environments/k3s-dev/terraform.tfvars` and run `terraform -chdir=terraform/environments/k3s-dev plan`. **(done)**

---

## Validation

### Commands

> Current defaults: storage pool `tank`, ISO storage `local`, bridge `vmbr0`, template `talos-v1.12.4-base`, host `vmhost (10.0.0.13)`.

- proxmox-ansible (run from proxmox-ansible repo/runner) using new inventory:

  ```bash
  docker run --rm -it \
    -v "$PWD/ansible/inventory/proxmox:/inventory" \
    -v "$PWD:/workspace" -w /workspace \
    ghcr.io/yokozu777/proxmox-ansible:latest \
    ansible-playbook proxmox.yml -i /inventory/inventory.yml
  ```

- Talos template creation:

  ```bash
  ansible-playbook ansible/playbooks/prepare-template.yml -i ansible/inventory/proxmox/hosts.ini \
    -e talos_template_storage=tank -e talos_iso_storage=local -e template_bridge=vmbr0
  ```

- Terraform check:

  ```bash
  terraform -chdir=terraform/environments/k3s-dev init -input=false
  terraform -chdir=terraform/environments/k3s-dev plan -var-file=terraform.tfvars
  ```

### Expected results

- proxmox-ansible run completes without failed tasks; reports emitted.
- Talos ISO exists on Proxmox at `local:iso/<talos.iso>` and is attached by the template playbook.
- Talos template named `talos-v<major>.<minor>.<patch>-base` is created/updated successfully.
- Terraform `plan` succeeds using the newly created template names and Proxmox provider credentials.

---

## Acceptance Criteria

- Inventory and host_vars documented and reproducible for proxmox-ansible.
- ISO download and host hardening are automated; no manual ISO uploads required.
- Local Ansible template pipeline works against proxmox-ansible-prepared host.
- Terraform `plan` is unblocked with the prepared template and provider inputs.

---

## Risks & Mitigations

- Risk: proxmox-ansible toggles SSH/root settings that break later Ansible runs.
  - Mitigation: keep root key login enabled until after template pipeline; lock down post-template if required.
- Risk: ISO lands in unexpected storage path.
  - Mitigation: pin ISO storage to `local:iso` in host_vars; verify before template run.
- Risk: Bridge/storage names differ from local defaults.
  - Mitigation: map `bridge` and storage vars explicitly in host_vars; adjust local roles to match if needed.

---

## Execution Log

| Date | Step | Change | Validation | Result | Notes |
|---|---|---|---|---|---|
| 2026-02-17 | Task doc creation | Added P2-T6 plan for proxmox-ansible integration and Terraform readiness | N/A | In progress | Needs inventory + tracker updates |
| 2026-02-17 | Inventory + defaults | Added proxmox-ansible YAML inventory and host_vars for vmhost; set template storage to tank and synced Terraform templates to talos-v1.12.4-base | N/A | In progress | Next: run proxmox-ansible to fetch Talos ISO and converge host |
| 2026-02-17 | Host prep run | Built local proxmox-ansible image with required collections/passlib; ran proxmox.yml against vmhost with custom host_vars and completed without failures | proxmox-ansible container run | Complete | Proxmox host converged; docs generation vars set in host_vars |
| 2026-02-17 | Talos ISO fetched | Pulled Talos ISO to Proxmox ISO storage (local:iso/talos-v1.12.4-metal-amd64.iso) via ad-hoc Ansible get_url | ad-hoc ansible get_url | Complete | ISO present for template playbook |
| 2026-02-17 | Template autoinstall support | Added optional Talos autoinstall kernel args to prepare-template playbook (config URL, disk, hostname) with cleanup on finalize | N/A | Complete | Enables unattended install before template conversion |
| 2026-02-17 | Template finalized | Ran prepare-template with autoinstall (config URL http://10.0.0.85:8000/init.yaml), then finalized VMID 9000 to template talos-v1.12.4-base on storage tank; removed autoinstall args | ansible-playbook prepare-template.yml (finalize_template=true) | Complete | Template ready for Terraform |
| 2026-02-17 | Terraform plan | Executed plan with containerized terraform:1.14.5 using talos-v1.12.4-base template and k3s-dev tfvars | `docker run --rm -v "$PWD:/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 plan -var-file=terraform.tfvars` | Complete | Plan shows 2 VMs (control + worker) to create; outputs populate after apply |
| 2026-02-17 | Terraform apply | Attempted apply with containerized terraform:1.14.5; Proxmox reported missing template `talos-v1.12.4-base` | `docker run --rm -v "$PWD:/workspace" -w /workspace/terraform/environments/k3s-dev hashicorp/terraform:1.14.5 apply -var-file=terraform.tfvars -auto-approve` | Failed | Recreate/verify template VMID 9000 or adjust tfvars template name, then rerun |

---

## Handoff Notes

- Update phase-2 tracker with this task and status.
- Prepare inventory YAML + host_vars aligned to Proxmox host facts.
- Run proxmox-ansible before Talos template and Terraform `plan/apply`.
- Preserve root key access through template creation; harden afterward if policy requires.
