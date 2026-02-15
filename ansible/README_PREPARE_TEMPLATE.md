Prepare VM template (cloud-init + DHCP + qemu-guest-agent)
=========================================================

Purpose
-------
This doc shows how to clone a cloud-init template in Proxmox, run the included Ansible playbook to ensure the guest is configured for DHCP and has `cloud-init` + `qemu-guest-agent` installed, and optionally convert the VM back into a template.

Prerequisites
-------------
- SSH access to the Proxmox host (user with permission to run `qm`)
- SSH access to the temporary VM (or use the Proxmox console)
- `ansible` installed on the machine you run the playbook from

Files added
-----------
- `ansible/playbooks/prepare-template.yml` — playbook that installs packages, configures netplan for DHCP, forces DHCP request, and (optionally) re-templates via SSH to Proxmox when `retemplate=true`.
- `ansible/inventory/prepare-template.ini` — example inventory; edit with the temporary VM IP, user, and SSH key.
- `scripts/prepare_template_ansible.sh` — helper to clone a template on the Proxmox host and start the VM.
- `scripts/retemplate_vm.sh` — helper to shutdown & convert a VM to a template (alternative to using the Ansible integrated retemplate).

Quick workflow
--------------
1. Clone template & start a temp VM on Proxmox (run on your workstation):

```bash
./scripts/prepare_template_ansible.sh <proxmox_host> <proxmox_user> <TEMPLATE_VMID> <NEW_VMID> <node>
# example:
./scripts/prepare_template_ansible.sh proxmox.example.com root@pam 9000 11000 vmhost
```

2. Find the temporary VM's IP:
- If guest agent is present, the helper prints IP; otherwise open the Proxmox console and log into the VM to see `ip addr`.

3. Update `ansible/inventory/prepare-template.ini` with the temp VM IP and ssh options. Example line:

```
10.0.0.69 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```

4. Run the playbook (no retemplate):

```bash
ansible-playbook -i ansible/inventory/prepare-template.ini ansible/playbooks/prepare-template.yml
```

5. Verify inside the VM (or via Proxmox console):
- `systemctl status cloud-init`
- `systemctl status qemu-guest-agent`
- `ip -4 addr show` and `/var/log/cloud-init.log`

6. When satisfied, convert to template either using the integrated playbook or the helper script.

Integrated retemplate (runs `qm` on Proxmox via SSH from the controller):

```bash
ansible-playbook -i ansible/inventory/prepare-template.ini \
  ansible/playbooks/prepare-template.yml \
  -e retemplate=true \
  -e proxmox_host=proxmox.example.com \
  -e proxmox_user='root@pam' \
  -e vmid=11000
```

Or run the standalone retemplate script:

```bash
./scripts/retemplate_vm.sh proxmox.example.com root@pam 11000 300
```

Troubleshooting
---------------
- If the VM doesn't get an IP: open Proxmox console and inspect `/var/log/cloud-init.log` and `journalctl -u cloud-init`.
- If cloud-init isn't applying Proxmox-provided `ipconfig0`, the template may use an incompatible cloud-init datasource; ensure the template uses NoCloud/ConfigDrive or install cloud-init and configure datasource accordingly.

Notes
-----
- This repo workflow expects `ipconfig0 = "ip=dhcp"` (Proxmox cloud-init) to work. The playbook forces DHCP via netplan and `dhclient` to recover VMs that weren't requesting DHCP on their own.
- The integrated re-template step SSHes to the Proxmox host and runs `qm` commands; use `retemplate=false` (default) if you prefer manual verification before templating.
