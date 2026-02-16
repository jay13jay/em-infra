Ansible k3s bootstrap
=====================

**Architecture:** See [docs/architecture-freeze.md](../docs/architecture-freeze.md) for the locked Phase 0 contract.

Overview
--------

This folder contains a minimal, readable Ansible scaffold to bootstrap a single-node k3s control plane and join workers. Terraform remains responsible for infrastructure provisioning; Ansible performs configuration and cluster bootstrap.

Principles
----------

- Use Ansible's terraform inventory plugin to generate hosts from Terraform outputs.
- Keep playbooks simple and idempotent.
- Avoid copying sensitive tokens; workers read the join token directly from the control node at runtime.
- Provide an empty `k3s_gpu` group for future GPU-specific tasks.

Quickstart
----------

1. Ensure Terraform has been applied for your environment (e.g. `terraform/environments/k3s-dev`).
2. Make sure Ansible has the terraform inventory plugin available (community plugins may be required).
3. Preview inventory:

   ansible-inventory -i ansible/inventory/terraform_inventory.yml --list

4. Run the site playbook:

   ansible-playbook -i ansible/inventory/terraform_inventory.yml ansible/playbooks/site.yml

Customisation
-------------

- Edit `ansible/group_vars/all.yml` to set `ssh_private_key_file`, `k3s_version`, or API wait timeouts.
- **SSH Key Contract:** Ensure `ssh_private_key_file` matches the public key you injected via Terraform's `ssh_authorized_keys` variable. See [architecture freeze docs](../docs/architecture-freeze.md#4-ssh-and-access) for details.

Collections / Inventory Plugin
-----------------------------

This repo supports using Ansible's `cloud.terraform` collection to build inventory
directly from Terraform state. Install the collection on your control machine or CI:

```bash
LANG=C.UTF-8 ansible-galaxy collection install cloud.terraform
```

Use `ansible/inventory/terraform_inventory.yml` (already configured) or
`ansible/inventory/terraform_state_local_example.yml` for a local state file.
If you prefer the `community.general` terraform plugin, the older plugin can also
be used but `cloud.terraform.terraform_state` is recommended for state-file-driven
inventories and has richer backend support.

Notes
-----

- This scaffold assumes Ubuntu 22.04 guests and SSH user `ubuntu` (consistent with Terraform modules).
- The inventory plugin config references the Terraform environment; update the path if you use a different environment.
