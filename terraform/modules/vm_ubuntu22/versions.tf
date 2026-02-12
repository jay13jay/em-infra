// Module-level provider/version constraints — match root terraform settings
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">= 2.9, < 4.0"
    }
  }
}
