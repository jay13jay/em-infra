# Windows + WSL2 + Docker Desktop (recommended setup)

Summary
- Preferred developer setup on Windows: WSL2 distro (Ubuntu) + Docker Desktop with **Use the WSL 2 based engine** enabled.

Key settings (exact names)
- Docker Desktop → Settings → General → **Use the WSL 2 based engine** = ON
- Docker Desktop → Settings → Resources → **WSL Integration** → enable your distro
- `%USERPROFILE%/.wslconfig`: `memory=8GB`, `processors=4`, `swap=2GB`, `localhostForwarding=true`
- `/etc/wsl.conf`: `[automount]` `options = "metadata,uid=1000,gid=1000"`

GPU (if applicable)
- Install NVIDIA Windows driver (WSL-enabled) and run `wsl nvidia-smi` to verify.
- Use prebuilt, digest-pinned CUDA base images for dev and CI to avoid repeated downloads.

Performance
- Keep active source inside WSL (`~/project`) — avoid editing via `C:\` mounts for heavy IO.
- Use Docker volumes for node_modules/build caches; prefer `workspaceMount` = volume in `devcontainer.json`.

Verification (minimal)
- `wsl -l -v`
- `docker info`
- `wsl nvidia-smi` (if GPU)
- `docker run --rm --gpus all nvidia/cuda:12.1-base-ubuntu22.04 nvidia-smi`
- `kubectl get nodes` (if running k8s locally)

Troubleshooting (quick)
- If Docker CLI is unavailable in WSL: restart Docker Desktop and run `wsl --shutdown`.
- If GPU containers fail: update Windows NVIDIA driver and `wsl --update`.

See `docs/guides/onboarding.md` for an actionable checklist for new devs.
