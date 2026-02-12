GPU Worker module
=================

Purpose
-------
This module provisions a GPU-enabled Ubuntu cloud-init VM on Proxmox by cloning the same template pattern used by `vm_ubuntu22`, and attaching a single physical NVIDIA GPU via PCI passthrough.

Key constraints
- One physical GPU per VM (no sharing, no vGPU)
- Module accepts PCI BDF only (e.g. `0000:03:00.0`)
- Default `x_vga` is false; enable only when required for the guest
- Mixed GPU models supported by using distinct host PCI IDs

Why this duplicates `vm_ubuntu22`
---------------------------------
This module intentionally duplicates the VM cloning and cloud-init configuration from `vm_ubuntu22` rather than composing it. The reason is to keep GPU-specific hostpci logic fully isolated: PCI passthrough requires changing the VM resource shape (hostpci assignments, optional flags) that would otherwise pollute the base module's API and complexity. Keeping the GPU concerns in a separate module makes it safe to maintain both plain VMs and GPU VMs without conditionalizing the base module or leaking passthrough flags into many call sites.

Host prerequisites (must be performed by operator / automation outside this module)
- IOMMU enabled on host kernel (intel_iommu=on or amd_iommu=on)
- Required kernel modules loaded on host: `vfio`, `vfio-pci`, `vfio_iommu_type1`
- Target GPU must be bound to `vfio-pci` (or otherwise available for passthrough) before attach; helper script included for operator use
- Verify IOMMU groups and avoid passing devices that share groups unless you understand the implications
- Ensure Proxmox/QEMU version supports PCI passthrough options used (`pcie=1`, `x-vga`)

Usage
-----
Example usage is provided in `examples/gpu_worker/main.tf`.

Notes
-----
- This module does not attempt to install NVIDIA drivers inside the guest; leave driver installation to cluster tooling or provisioning automation.
- The module will not rebind host drivers automatically; a helper script is included for manual or operator-initiated binding. Automating host driver changes from Terraform can be risky and is intentionally avoided.
