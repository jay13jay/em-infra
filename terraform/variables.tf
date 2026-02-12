// Variables for Proxmox provider configuration
// Best practice: do NOT put secrets in VCS. Prefer environment variables or a secret manager.

variable "proxmox_api_url" {
  description = "Proxmox API URL (example: https://proxmox.local:8006/api2/json). Can be supplied via PM_API_URL env var."
  type        = string
  default     = null
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token id (format: user@realm!tokenname). Highly sensitive — prefer PM_API_TOKEN_ID env var or a secret manager."
  type        = string
  sensitive   = true
  default     = null
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret (UUID). Highly sensitive — prefer PM_API_TOKEN_SECRET env var or a secret manager."
  type        = string
  sensitive   = true
  default     = null
}

variable "proxmox_user" {
  description = "Proxmox username (e.g. terraform-prov@pve). Not required when using API token; prefer PM_USER env var for username/password auth."
  type        = string
  default     = null
}

// Notes for operators:
// - For CI / local dev: export PM_API_TOKEN_ID and PM_API_TOKEN_SECRET instead of committing values.
// - Consider integrating Vault/Secrets Manager and using the terraform provider's external data source
//   or the Vault provider to surface credentials at runtime.
