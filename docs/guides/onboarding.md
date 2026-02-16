# Developer onboarding (short)

1. Install: Windows → enable WSL2, Docker Desktop (WSL2 engine), VS Code + Remote‑WSL + Dev Containers. Linux users: Docker + VS Code.
2. Clone the repo inside WSL: `git clone <repo> ~/em-infra && cd ~/em-infra`.
3. Quick smoke: `docker compose up --build` (compose-first) or `skaffold dev -p dev` (k8s parity).
4. GPU users: follow `docs/guides/windows-dev.md` to install drivers and run `wsl nvidia-smi`.
5. Run checks: `hadolint services/example-service/Dockerfile` and `kubeval k8s/overlays/dev`.
6. If slow builds: move workspace to WSL FS or use the devcontainer volume workspace.

Useful commands
- `wsl -l -v`  `docker info`  `docker run --rm hello-world`  `kubectl get nodes`

If something breaks, capture Docker diagnostics and open an issue with diagnostics ID.
