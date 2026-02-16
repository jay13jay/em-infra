Ansible Infrastructure Orchestration
====================================

**Architecture:** See [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md) for the Talos contract.

Overview
--------

This folder contains automation scaffolding for infrastructure bring-up. Terraform remains responsible for VM provisioning; Ansible orchestrates bootstrap workflows.

Principles
----------

- For Talos workflows, use inventory intent (static/reserved addresses) and `talosctl` for post-boot cluster discovery.
- Keep playbooks simple and idempotent.
- Avoid relying on guest-agent-only metadata as a source of truth.

Quickstart
----------

Talos-oriented workflow:

1. Ensure Terraform has been applied for your environment.
2. Bootstrap Talos cluster (per roadmap/architecture flow).
3. Retrieve live cluster information with `talosctl`:

   ```bash
   talosctl --talosconfig <path-to-talosconfig> --endpoints <control-plane-ip> --nodes <control-plane-ip> get members
   talosctl --talosconfig <path-to-talosconfig> --endpoints <control-plane-ip> kubeconfig ./kubeconfig
   ```

Legacy k3s workflow remains available in existing playbooks (`site.yml`, `control-plane.yml`, `workers.yml`) and can still use Terraform inventory where guest-agent IP discovery is present.

Customisation
-------------

- Edit `ansible/group_vars/all.yml` for legacy k3s tuning (`ssh_private_key_file`, `k3s_version`, API wait timeouts).

Collections / Inventory Plugin
-----------------------------

Terraform dynamic inventory is supported for legacy SSH-based workflows.
It is not the canonical path for Talos nodes because Talos does not provide qemu guest-agent IP metadata.

If you need legacy dynamic inventory, install the collection on your control machine or CI:

```bash
LANG=C.UTF-8 ansible-galaxy collection install cloud.terraform
```

Use `ansible/inventory/terraform_inventory.yml` (legacy path) or
`ansible/inventory/terraform_state_local_example.yml` for a local state file.
If you prefer the `community.general` terraform plugin, the older plugin can also
be used but `cloud.terraform.terraform_state` is recommended for state-file-driven
inventories and has richer backend support.

Notes
-----

- Talos workflows should prefer static/reserved node addresses and `talosctl` state inspection.
- The inventory plugin config references the Terraform environment and is intended for non-Talos SSH-based flows.
