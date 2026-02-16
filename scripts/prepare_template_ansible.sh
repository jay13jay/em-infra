#!/usr/bin/env bash
# helper script to clone a template VM on Proxmox and run the Ansible playbook
# Usage: prepare_template_ansible.sh <proxmox_host> <proxmox_user> <template_vmid> <new_vmid> <node>

set -euo pipefail

PROXMOX_HOST=${1-}
PROXMOX_USER=${2-}
TEMPLATE_VMID=${3-}
NEW_VMID=${4-}
NODE=${5-}

if [[ -z "$PROXMOX_HOST" || -z "$PROXMOX_USER" || -z "$TEMPLATE_VMID" || -z "$NEW_VMID" || -z "$NODE" ]]; then
  cat <<EOF
Usage: $0 <proxmox_host> <proxmox_user> <template_vmid> <new_vmid> <node>
Example: $0 proxmox.example.com root@pam 9000 11000 vmhost
Notes:
 - This script requires SSH access to the Proxmox host as the provided user.
 - The template must exist and be a cloud-init compatible VM/template.
 - The script only clones and starts the VM; it then prints next steps for running the Ansible playbook.
EOF
  exit 1
fi

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

echo "Cloning template ${TEMPLATE_VMID} -> ${NEW_VMID} on node ${NODE}..."
ssh ${SSH_OPTS} ${PROXMOX_USER}@${PROXMOX_HOST} "qm clone ${TEMPLATE_VMID} ${NEW_VMID} --name temp-template-fix-${NEW_VMID} --full 1 --target ${NODE}"

echo "Starting VM ${NEW_VMID}..."
ssh ${SSH_OPTS} ${PROXMOX_USER}@${PROXMOX_HOST} "qm start ${NEW_VMID}"

echo "VM started. Attempting to discover IP via guest agent (may be empty if qemu-guest-agent not installed)..."
ssh ${SSH_OPTS} ${PROXMOX_USER}@${PROXMOX_HOST} "qm guest exec ${NEW_VMID} -- bash -lc 'ip -4 -o addr show' || true"

cat <<EOF
Next steps:
1) If the VM obtained an IP, update ansible/inventory/prepare-template.ini with the IP and user.
   Example:
     10.0.0.69 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

2) Run the Ansible playbook from the repo root:
   ansible-playbook -i ansible/inventory/prepare-template.ini ansible/playbooks/prepare-template.yml

3) After the playbook ensures DHCP/qemu-guest-agent, test that the VM has an IP.

4) When satisfied, shut down and convert the VM back to a template on the Proxmox host:
   ssh ${SSH_OPTS} ${PROXMOX_USER}@${PROXMOX_HOST} "qm shutdown ${NEW_VMID} && qm template ${NEW_VMID}"

If the VM did not get an IP and you cannot ssh into the guest, open the Proxmox Console for ${NEW_VMID} and inspect /var/log/cloud-init.log and systemctl status cloud-init and qemu-guest-agent.
EOF
