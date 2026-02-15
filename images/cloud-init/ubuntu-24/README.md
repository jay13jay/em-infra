This folder contains cloud-init templates used to generate seed ISOs for Proxmox.

- `user-data.j2`: cloud-init user-data template (inject `build_ssh_pubkey`).
- `meta-data.j2`: meta-data template.

Use `ansible-playbook -i ansible/inventory/preseed/hosts.ini ansible/playbooks/build-seed.yml` to render and build the seed ISO.
