Module: vm_ubuntu22 — reusable Ubuntu 22.04 VM for Proxmox

Summary
- Clones a cloud-init–capable Ubuntu 22.04 template (preferred).
- Injects SSH keys via cloud-init and optionally waits for the QEMU guest agent to report an IP.
- Exposes simple inputs for name/node/cpu/memory/disk/bridge and useful outputs (vmid, ip).

Quick usage

```hcl
module "cp-ubuntu" {
  source = "../../modules/vm_ubuntu22"

  name                  = "cp-01"
  node                  = "pve01"
  template              = "ubuntu-22-04-cloudinit" // template name or VMID
  cores                 = 2
  memory_mb             = 4096
  disk_gb               = 40
  disk_pool             = "local-lvm"
  network_bridge        = "vmbr0"
  ssh_authorized_keys   = [file("~/.ssh/id_rsa.pub")]
}
```

Important prerequisites
- The template referenced by `template` must be an Ubuntu 22.04 image that has **cloud-init** and **qemu-guest-agent** installed and configured. Without those, cloud-init injections or IP discovery will fail.
- Module assumes DHCP by default. To use a static IP set `dhcp = false` and provide `static_ip_config` in the form `ip=192.168.1.50/24,gw=192.168.1.1`.

Notes on image import
- Primary/most-tested path: clone an existing validated template.
- Optional: import an upstream cloud image and convert it to a template (documented example provided in `terraform/examples/ubuntu/IMPORT.md`) — this flow is intentionally manual in this repository to avoid platform-specific local-exec assumptions.

Outputs
- `vmid`, `vm_name`, `node`, `ip_address` (first IPv4 reported by guest agent, may be null)

Troubleshooting
- If `ip_address` is null: verify `qemu-guest-agent` is installed in the template and cloud-init finished successfully (check cloud-init logs in the VM console).
- If clone fails: confirm `template` exists on the target `node` and that the `disk_pool` has capacity.

References
- See `terraform/examples/ubuntu` for runnable examples and `terraform/README.md` for provider setup and credentials.
