#!/usr/bin/env bash
set -euo pipefail

# prepare_template.sh
# Usage: ./prepare_template.sh -H host -u user -p pass -T TEMPLATE_NAME -N TARGET_TEMPLATE_NAME [-s storage] [-n node] [-k ssh_key] [--keep-snippet]
# This script runs from your workstation and SSHs to the Proxmox host to:
# 1. Find TEMPLATE_NAME (existing template VM name)
# 2. Reserve a new VMID
# 3. Clone the template to a temporary VM
# 4. Upload a cloud-init snippet that installs qemu-guest-agent on first boot
# 5. Configure the temp VM to use the snippet and enable the guest agent
# 6. Start the VM and wait for it to shut itself down after script runs
# 7. Rename the VM to the TARGET_TEMPLATE_NAME and convert it to a template

print_usage(){
  cat <<EOF
Usage: $0 -H host -u user -p pass -T TEMPLATE_NAME -N TARGET_TEMPLATE_NAME [-s storage] [-n node] [-k ssh_key] [--keep-snippet]

Examples:
  # run using password auth
  ./prepare_template.sh -H 10.0.0.13 -u root -p 'password' -T ubuntu-22-cloudinit-template-temp -N ubuntu-22-cloudinit-template -s local -n vmhost

  # run using key-based auth
  ./prepare_template.sh -H 10.0.0.13 -u root -k ~/.ssh/id_rsa -T ubuntu-22-cloudinit-template-temp -N ubuntu-22-cloudinit-template

This script will place a file in /var/lib/vz/snippets/ on the Proxmox host and remove it by default.
EOF
}

# Defaults
STORAGE="local"
NODE="vmhost"
SNIPPET_NAME="qga-install-$(date +%s).yaml"
KEEP_SNIPPET=0
SSH_KEY=""
PROXMOX_PASS=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -H) PROXMOX_HOST="$2"; shift 2;;
    -u) PROXMOX_USER="$2"; shift 2;;
    -p) PROXMOX_PASS="$2"; shift 2;;
    -T) TEMPLATE_NAME="$2"; shift 2;;
    -N) TARGET_TEMPLATE_NAME="$2"; shift 2;;
    -s) STORAGE="$2"; shift 2;;
    -n) NODE="$2"; shift 2;;
    -k) SSH_KEY="$2"; shift 2;;
    --keep-snippet) KEEP_SNIPPET=1; shift;;
    -h|--help) print_usage; exit 0;;
    *) echo "Unknown arg: $1"; print_usage; exit 1;;
  esac
done

if [[ -z "${PROXMOX_HOST:-}" || -z "${PROXMOX_USER:-}" || -z "${TEMPLATE_NAME:-}" || -z "${TARGET_TEMPLATE_NAME:-}" ]]; then
  echo "Missing required args"; print_usage; exit 1
fi

# Build SSH/SSHCP command wrappers
SSH_CMD_BASE=(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l "$PROXMOX_USER" "$PROXMOX_HOST")
SCP_CMD_BASE=(scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)

if [[ -n "$SSH_KEY" ]]; then
  SSH_CMD_BASE=(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l "$PROXMOX_USER" "$PROXMOX_HOST")
  SCP_CMD_BASE=(scp -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)
elif [[ -n "${PROXMOX_PASS:-}" ]]; then
  if ! command -v sshpass >/dev/null 2>&1; then
    echo "sshpass is required for password auth. Please install sshpass or provide an SSH key."; exit 1
  fi
  SSH_CMD_BASE=(sshpass -p "$PROXMOX_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l "$PROXMOX_USER" "$PROXMOX_HOST")
  SCP_CMD_BASE=(sshpass -p "$PROXMOX_PASS" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)
fi

run_ssh(){
  "${SSH_CMD_BASE[@]}" -- "$@"
}

run_scp(){
  # usage: run_scp localpath remote:path
  "${SCP_CMD_BASE[@]}" "$1" "$PROXMOX_USER"@"$PROXMOX_HOST":"$2"
}

echo "Using Proxmox host: $PROXMOX_HOST (node: $NODE), storage: $STORAGE"

# 1) find template VMID by name
TEMPLATE_VMID=$(run_ssh pvesh get /nodes/$NODE/qemu 2>/dev/null | awk -F '"' '/"vmid"/ {vmid=$4} /"name"/ {name=$4; if (name == "'"$TEMPLATE_NAME"'") print vmid}' || true)
# fallback parsing via qm list if pvesh output parsing fails
if [[ -z "$TEMPLATE_VMID" ]]; then
  TEMPLATE_VMID=$(run_ssh qm list 2>/dev/null | awk -v name="$TEMPLATE_NAME" '$2==name {print $1}')
fi

if [[ -z "$TEMPLATE_VMID" ]]; then
  echo "Template named '$TEMPLATE_NAME' not found on node $NODE"; exit 1
fi

echo "Found template VMID: $TEMPLATE_VMID"

# 2) reserve new VMID
NEW_VMID=$(run_ssh pvesh get /cluster/nextid)
if [[ -z "$NEW_VMID" ]]; then
  echo "Unable to get a new VMID"; exit 1
fi

TMP_VM_NAME="${TARGET_TEMPLATE_NAME}-build-$NEW_VMID"

echo "Cloning template $TEMPLATE_VMID -> $NEW_VMID (name: $TMP_VM_NAME)"
run_ssh qm clone "$TEMPLATE_VMID" "$NEW_VMID" --name "$TMP_VM_NAME" --full true

# 3) create snippet on the Proxmox host
SNIPPET_PATH="/var/lib/vz/snippets/$SNIPPET_NAME"
read -r -d '' SNIPPET_CONTENT <<'EOF'
#cloud-config
runcmd:
  - apt-get update
  - apt-get install -y qemu-guest-agent
  - systemctl enable --now qemu-guest-agent
  - shutdown -h now
EOF

# write snippet using ssh heredoc
echo "Uploading cloud-init snippet to $SNIPPET_PATH"
"${SSH_CMD_BASE[@]}" "cat > $SNIPPET_PATH <<'SNIP'
$SNIPPET_CONTENT
SNIP"

# 4) configure VM to use the snippet and enable agent
echo "Configuring VM $NEW_VMID to use snippet and enabling guest agent"
run_ssh qm set "$NEW_VMID" --cicustom user=local:snippets/$SNIPPET_NAME
run_ssh qm set "$NEW_VMID" --agent 1

# 5) start the VM and wait for it to shutdown (cloud-init will call shutdown)
echo "Starting VM $NEW_VMID"
run_ssh qm start "$NEW_VMID"

echo "Waiting for VM to shut down (this indicates the cloud-init script finished). This may take a few minutes..."
MAX_RETRIES=72  # ~6 minutes (72*5s)
SLEEP=5
for i in $(seq 1 $MAX_RETRIES); do
  STATUS=$(run_ssh qm status "$NEW_VMID" 2>/dev/null | awk '{print $2}' || true)
  echo "  [$i] status=$STATUS"
  if [[ "$STATUS" == "stopped" ]]; then
    echo "VM $NEW_VMID stopped; continuing"
    break
  fi
  sleep $SLEEP
done

if [[ "$STATUS" != "stopped" ]]; then
  echo "Timeout waiting for VM to stop. Check VM $NEW_VMID manually."; exit 2
fi

# 6) rename and convert to template
echo "Renaming VM $NEW_VMID -> $TARGET_TEMPLATE_NAME and converting to template"
run_ssh qm set "$NEW_VMID" --name "$TARGET_TEMPLATE_NAME"
run_ssh qm template "$NEW_VMID"

# 7) cleanup snippet unless requested to keep
if [[ "$KEEP_SNIPPET" -eq 0 ]]; then
  echo "Removing snippet $SNIPPET_PATH"
  run_ssh rm -f "$SNIPPET_PATH" || true
else
  echo "Keeping snippet on host: $SNIPPET_PATH"
fi

echo "Template creation complete: $TARGET_TEMPLATE_NAME (cloned from $TEMPLATE_NAME)"

exit 0
