# Terraform — Proxmox foundation (local/homelab)

Short and focused instructions for local-only use. This workspace contains only provider configuration — no VMs are defined yet.

## Quick facts ✅
- Provider: `Telmate/proxmox` (pinned in `providers.tf`).
- Intended usage: **local single-operator homelab** (you). No CI required.
- Secrets: keep out of VCS — use environment variables or a secrets manager.
- TLS: `pm_tls_insecure = true` is explicit and acceptable for this homelab setup.

---

## Files of interest
- `providers.tf` — provider + required_providers/version constraints
- `variables.tf` — sensitive variables (default to `null`) — prefer env vars
- `terraform.tfvars.example` — example (DO NOT commit real secrets)
- `.gitignore` — ignores state and `terraform.tfvars`

---

## Quick start (Git Bash) ⚡
1. Create a Proxmox API token (run on your Proxmox host or via API):

   pveum user token add terraform-prov@pve mytoken

   Note: the token id format is `user@realm!tokenname` and the secret (UUID)
   is shown only at creation.

2. Export credentials to the environment (Git Bash):

   export PM_API_URL='https://proxmox.local:8006/api2/json'
   export PM_API_TOKEN_ID='terraform-prov@pve!mytoken'
   export PM_API_TOKEN_SECRET='00000000-0000-0000-0000-000000000000'

   Tip: you can add the three `export` lines to a local `env.sh` file and `source env.sh` when working.

3. Initialize and validate the configuration:

   terraform -chdir=terraform init
   terraform -chdir=terraform validate

4. Create a plan (safe, read-only):

   terraform -chdir=terraform plan -out=terraform/tfplan

---

## Security & best-practices (short) 🔐
- Never commit `terraform.tfvars` with secrets. `.gitignore` already excludes it.
- Prefer `PM_API_*` environment variables or a secret manager (Vault, etc.).
- API token is recommended over username/password.
- For production: set `pm_tls_insecure = false` and use a proper CA-signed certificate.

---

## Troubleshooting (common issues) ⚠️
- "authentication failed": verify `PM_API_TOKEN_ID` includes the `!tokenname` suffix and the secret is correct.
- "certificate verify failed": this config intentionally sets `pm_tls_insecure = true`. To fix properly, install a CA-signed cert on Proxmox and set `pm_tls_insecure = false`.
- "resource not found / no resources": expected — provider is configured but no VM resources are defined yet.

---

## Where to add resources next
- Add environment-level resources under `terraform/` (or create `terraform/modules/` for reusable VM modules).

## Next suggestions (optional)
- If you want credentials injected from Vault or a Windows secret store, I can add an example.

---

## New: `vm_ubuntu22` module (Ubuntu 22.04)
A reusable, control-plane–suitable VM module has been added at `terraform/modules/vm_ubuntu22/` with a runnable example in `terraform/examples/ubuntu/`.

Quick notes:
- Primary flow: **clone** a cloud-init–capable Ubuntu 22.04 template (must include cloud-init + qemu-guest-agent).
- Defaults assume DHCP, `vmbr0` and `local-lvm` (adjust via module inputs).
- Example usage: `terraform/examples/ubuntu/main.tf` + `terraform/examples/ubuntu/terraform.tfvars.example`.

Run the example locally:

1. export the `PM_API_*` environment variables (see above)
2. terraform -chdir=terraform/examples/ubuntu init
3. terraform -chdir=terraform/examples/ubuntu plan -var-file=terraform.tfvars

The module README contains prerequisites and troubleshooting tips.
