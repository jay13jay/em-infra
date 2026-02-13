// Proxmox provider configuration (Telmate provider)
// - Minimal, well-commented
// - Auth is intentionally left to variables or environment variables (safer)
// - THIS FILE DOES NOT CREATE ANY VM RESOURCES

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      # Pin to a specific v3 pre-release that includes Proxmox 9 fixes
      version = "3.0.2-rc01"
    }
  }
}

# Provider: uses variables if supplied, otherwise provider will read corresponding
# environment variables (PM_API_URL, PM_API_TOKEN_ID, PM_API_TOKEN_SECRET, PM_USER, PM_PASS).
provider "proxmox" {
  # API endpoint (required)
  pm_api_url = var.proxmox_api_url

  # Authentication (prefer API token). These variables default to null so you can
  # supply credentials via environment variables or a secret manager instead.
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_user             = var.proxmox_user

  # Homelab: allow self-signed certificates but make the acceptance explicit
  pm_tls_insecure = true

  # Debugging helpers (disabled by default) - enable only while troubleshooting
  # pm_debug = false
  # pm_log_enable = false
}
