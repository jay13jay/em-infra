# Module: proxmox-talos-vm — Talos Linux VM for Proxmox

## Summary

Clones a Talos template and provisions a Talos node without cloud-init or qemu-guest-agent assumptions.

This module is designed specifically for Talos Linux immutable infrastructure:
- No cloud-init configuration
- No qemu-guest-agent dependency
- No SSH access expectations
- Optional GPU PCI passthrough support

## Architecture

See [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../../../../docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md) for the full Talos architecture contract.

### Key Principles

1. **Immutable Nodes**: Talos nodes have no SSH, no package manager, no config drift
2. **VM Lifecycle Only**: Terraform manages VM creation/deletion; Talos manages OS configuration
3. **No Guest Agent**: Talos doesn't support qemu-guest-agent; use static IPs or DHCP reservations
4. **Machine Config Injection**: Talos machine config is injected via separate mechanism (ISO or network URL)

## Quick Usage

```hcl
module "talos_control_plane" {
  source = "../../modules/proxmox-talos-vm"

  name           = "k3s-dev-control-1"
  node           = "pve"
  template       = "talos-v1.12.4-base"
  cores          = 4
  memory_mb      = 8192
  disk_gb        = 40
  disk_pool      = "tank"
  network_bridge = "vmbr0"
}
```

## GPU Passthrough Example

```hcl
module "talos_gpu_worker" {
  source = "../../modules/proxmox-talos-vm"

  name           = "k3s-dev-gpu-1"
  node           = "pve"
  template       = "talos-v1.12.4-base"
  cores          = 8
  memory_mb      = 16384
  disk_gb        = 80
  disk_pool      = "tank"
  network_bridge = "vmbr0"
  
  # GPU passthrough
  gpu_pci_bdf    = "0000:01:00.0"
  gpu_pcie_mode  = true
  gpu_rombar     = true
}
```

## Prerequisites

### Talos Template

The template referenced by `template` must be a prepared Talos base template:
- Created using `ansible/playbooks/prepare-template.yml`
- Contains Talos OS only (no machine config, no cluster identity)
- Named following pattern: `talos-v<major>.<minor>.<patch>-base`

See `ansible/README_PREPARE_TEMPLATE.md` for template preparation instructions.

### Network Addressing

Since Talos doesn't report IPs via guest agent:
1. Use static IP assignments in Proxmox, OR
2. Use DHCP reservations based on MAC address, OR
3. Define predictable addressing in your cluster inventory

The `ip_address` output will likely be `null`. Use `talosctl` to discover node IPs after bootstrap.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | string | (required) | VM name in Proxmox |
| `node` | string | (required) | Proxmox node name |
| `template` | string | (required) | Talos template name or VMID |
| `cores` | number | 2 | Number of CPU cores |
| `memory_mb` | number | 4096 | Memory in MB |
| `disk_gb` | number | 40 | Disk size in GB |
| `disk_pool` | string | "local-lvm" | Storage pool for VM disk |
| `network_bridge` | string | "vmbr0" | Network bridge name |
| `gpu_pci_bdf` | string | null | Optional GPU PCI BDF (e.g., "0000:01:00.0") |
| `gpu_pcie_mode` | bool | true | Enable PCIe passthrough mode for GPU |
| `gpu_rombar` | bool | true | Enable ROM BAR for GPU passthrough |
| `onboot` | bool | true | Start VM on Proxmox boot |

## Outputs

| Name | Description |
|------|-------------|
| `vmid` | Proxmox VM ID |
| `vm_name` | VM name |
| `node` | Proxmox node hosting this VM |
| `ip_address` | First reported IP (may be null; Talos has no guest agent) |
| `mac_address` | MAC address of first network interface |

## Differences from vm_ubuntu22 Module

| Feature | vm_ubuntu22 | proxmox-talos-vm |
|---------|-------------|------------------|
| cloud-init | ✓ Required | ✗ Not used |
| qemu-guest-agent | ✓ Expected | ✗ Not supported |
| SSH key injection | ✓ Via cloud-init | ✗ No SSH access |
| IP discovery | ✓ Via guest agent | ⚠️ Likely null |
| OS type | cloud-init | l26 (generic Linux) |
| Machine config | N/A | External injection required |

## Talos Bootstrap Flow

1. **Provision VMs** (this module)
2. **Generate Talos machine configs** (Ansible playbook)
3. **Apply machine configs** (via talosctl or config URL)
4. **Bootstrap cluster** (via talosctl bootstrap)
5. **Retrieve kubeconfig** (via talosctl kubeconfig)

This module handles step 1 only. Steps 2-5 are orchestrated outside Terraform.

## Troubleshooting

### IP address is null

**Expected behavior**: Talos doesn't support qemu-guest-agent, so Terraform cannot auto-discover IPs.

**Solution**: Use one of these approaches:
- Define static IPs in Proxmox network config
- Use DHCP reservations based on MAC address
- Discover IPs post-bootstrap via `talosctl get members`

### Clone fails with "template not found"

**Check**:
1. Template exists on the specified Proxmox node
2. Template name matches exactly (case-sensitive)
3. Template was properly finalized via `qm template <vmid>`

**Fix**: Re-run `ansible/playbooks/prepare-template.yml` with `-e finalize_template=true`

### GPU passthrough not working

**Prerequisites**:
1. GPU must be bound on Proxmox host (not in use by host)
2. IOMMU must be enabled in BIOS/kernel
3. PCI BDF must match exactly (`lspci -nn` on host)

See `terraform/modules/gpu_worker/README.md` for GPU binding instructions.

## References

- Architecture contract: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](../../../../docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- Talos documentation: https://www.talos.dev/
- Template preparation: `ansible/playbooks/prepare-template.yml`
