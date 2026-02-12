Ansible k3s bootstrap
=====================

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

Notes
-----

- This scaffold assumes Ubuntu 22.04 guests and SSH user `ubuntu` (consistent with Terraform modules).
- The inventory plugin config references the Terraform environment; update the path if you use a different environment.
