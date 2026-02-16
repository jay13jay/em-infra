# scripts/prepare_template.sh

Purpose: clone an existing Proxmox cloud-init template, run a one-time cloud-init snippet to install qemu-guest-agent, and convert the VM back to a template.

Quick usage

Password auth (requires `sshpass` on your workstation):

```bash
./scripts/prepare_template.sh -H PROXMOX_IP -u root -p 'PASSWORD' -T EXISTING_TEMPLATE_NAME -N FINAL_TEMPLATE_NAME -n NODE
```

Key auth:

```bash
./scripts/prepare_template.sh -H PROXMOX_IP -u root -k ~/.ssh/id_rsa -T EXISTING_TEMPLATE_NAME -N FINAL_TEMPLATE_NAME -n NODE
```

Notes
- Requires SSH access to the Proxmox host with permissions to clone/modify VMs and write `/var/lib/vz/snippets/`.
- The script uploads a temporary cloud-init snippet that installs and enables `qemu-guest-agent`, boots the clone, waits for the snippet to shut the guest down, then converts the VM into the target template name.
- Add `--keep-snippet` to preserve the snippet on the host for debugging.
