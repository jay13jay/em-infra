Talos Base Template Preparation (Proxmox + Ansible)
===================================================

Purpose
-------
This is the canonical **pre-Terraform** workflow to create a Talos base template on Proxmox.

For Talos, template preparation is intentionally simple:

1. Upload Talos ISO to Proxmox ISO storage
2. Create installer VM
3. Boot from ISO and install Talos to disk
4. Power off VM
5. Convert VM to template

The template must contain **Talos OS only** (no machine config, no cluster identity).

Template Naming Contract
------------------------
Use:

- `talos-v<major>.<minor>.<patch>-base`
- Example: `talos-v1.12.4-base`

This naming is validated by `ansible/playbooks/prepare-template.yml`.

Prerequisites
-------------
- Proxmox host in `ansible/inventory/proxmox/hosts.ini`
- SSH access to Proxmox host with permission to run `qm` and `pvesm`
- Talos ISO present on Proxmox ISO storage (default expectation):
  - storage: `local`
  - filename: `talos-v1.12.4-metal-amd64.iso`

Example ISO upload from your workstation:

```bash
scp ./talos-v1.12.4-metal-amd64.iso root@<proxmox-host>:/var/lib/vz/template/iso/
```

Step 1: Build VM + boot installer
---------------------------------
Run:

```bash
ansible-playbook -i ansible/inventory/proxmox/hosts.ini ansible/playbooks/prepare-template.yml \
  -e talos_version=1.12.4 \
  -e talos_template_vmid=9000 \
  -e talos_template_storage=local-lvm \
  -e template_bridge=vmbr0
```

What this does:
- Verifies ISO exists in Proxmox storage
- Creates/updates VM config
- Attaches Talos ISO and sets boot order
- Starts installer VM

Then open the Proxmox console for VM `9000` and install Talos to disk.

Step 2: Finalize template
-------------------------
After Talos install is complete and VM is powered off:

```bash
ansible-playbook -i ansible/inventory/proxmox/hosts.ini ansible/playbooks/prepare-template.yml \
  -e talos_version=1.12.4 \
  -e talos_template_vmid=9000 \
  -e finalize_template=true
```

What this does:
- Ensures VM is stopped
- Sets boot order to disk
- Detaches installer ISO
- Sets final template name (`talos-v1.12.4-base`)
- Converts VM to template

Terraform usage
---------------
Use the same template name in:

- `control_plane_template`
- `worker_template`
- `gpu_worker_template`

Example:

```hcl
control_plane_template = "talos-v1.12.4-base"
worker_template        = "talos-v1.12.4-base"
gpu_worker_template    = "talos-v1.12.4-base"
```

Notes
-----
- Talos is immutable; do not run guest package provisioning inside the node.
- Do not rely on `qemu-guest-agent` for Talos node discovery.
- Bootstrap/runtime discovery should use planned node addressing and `talosctl`.
