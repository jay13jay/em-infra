#!/usr/bin/env bash
# Simple helper to bind a PCI device to vfio-pci on the Proxmox host.
# Usage: sudo ./bind_gpu.sh 0000:03:00.0

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <PCI_BDF> (e.g. 0000:03:00.0)"
  exit 2
fi

BDF="$1"

echo "Binding $BDF to vfio-pci"

if [ ! -e "/sys/bus/pci/devices/$BDF" ]; then
  echo "Device /sys/bus/pci/devices/$BDF not found" >&2
  exit 3
fi

vendor=$(cat /sys/bus/pci/devices/$BDF/vendor)
device=$(cat /sys/bus/pci/devices/$BDF/device)

echo "Vendor: $vendor Device: $device"

echo "Unbinding current driver (if any)"
if [ -e "/sys/bus/pci/devices/$BDF/driver/unbind" ]; then
  echo $BDF > /sys/bus/pci/devices/$BDF/driver/unbind || true
fi

echo "Binding to vfio-pci"
echo "$vendor $device" > /sys/bus/pci/drivers/vfio-pci/new_id || true
echo $BDF > /sys/bus/pci/drivers/vfio-pci/bind

echo "Done. Verify with: lspci -k -s $BDF"
