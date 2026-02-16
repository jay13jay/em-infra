#!/usr/bin/env bash
set -euo pipefail

PROXMOX_HOST=${1-}
PROXMOX_USER=${2-}
VMID=${3-}
TIMEOUT=${4-300}

if [[ -z "$PROXMOX_HOST" || -z "$PROXMOX_USER" || -z "$VMID" ]]; then
  cat <<EOF
Usage: $0 <proxmox_host> <proxmox_user> <vmid> [timeout_seconds]
Example: $0 proxmox.example.com root@pam 11000 300
This will attempt a graceful shutdown of the VM and convert it to a template.
EOF
  exit 1
fi

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

echo "Requesting graceful shutdown for VM ${VMID} on ${PROXMOX_HOST}..."
ssh ${SSH_OPTS} ${PROXMOX_USER}@${PROXMOX_HOST} "qm shutdown ${VMID}" || true

echo "Waiting for VM ${VMID} to stop (timeout ${TIMEOUT}s)..."
elapsed=0
interval=5
while true; do
  status=$(ssh ${SSH_OPTS} ${PROXMOX_USER}@${PROXMOX_HOST} "qm status ${VMID} 2>/dev/null" || true)
  if [[ "$status" == "status: stopped" || "$status" == "status: stopped\n" ]]; then
    echo "VM ${VMID} is stopped."
    break
  fi
  if (( elapsed >= TIMEOUT )); then
    echo "Timeout waiting for shutdown. Attempting hard stop..."
    ssh ${SSH_OPTS} ${PROXMOX_USER}@${PROXMOX_HOST} "qm stop ${VMID}" || true
    sleep 3
    break
  fi
  sleep ${interval}
  elapsed=$((elapsed + interval))
done

echo "Converting VM ${VMID} to template..."
ssh ${SSH_OPTS} ${PROXMOX_USER}@${PROXMOX_HOST} "qm template ${VMID}"

echo "Conversion requested. Verify in Proxmox web UI or with: qm status ${VMID}"
