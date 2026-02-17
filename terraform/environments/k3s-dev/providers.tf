terraform {
  required_version = ">= 1.14.5, < 1.15.0"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_user             = var.proxmox_user
  pm_password         = var.proxmox_password
  # Disable minimum permission check to support older provider behavior / Proxmox 9 differences
  pm_minimum_permission_check = false
  pm_tls_insecure     = true
}
