// Module-level provider/version constraints — match root terraform settings
terraform {
  required_version = ">= 1.14.5, < 1.15.0"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}
