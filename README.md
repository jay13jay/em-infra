# em-infra — infrastructure (source of truth)

Canonical infrastructure for the project: Dockerfiles, Kubernetes manifests (Helm/Kustomize), Terraform modules and developer tooling (devcontainers, Skaffold/Tilt).

Quickstart (developer)

- Clone into your WSL distro or Linux machine (recommended).
- `docker compose up --build` → fast compose-first iteration.
- `skaffold dev -p dev` → k8s-parity local dev (requires kind/k3d).

See the documentation index: [docs/README.md](docs/README.md)

Core infra docs:

- Docs home/index: [docs/README.md](docs/README.md)
- Talos architecture contract: [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md)
- Infrastructure roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](docs/planning/infra-roadmap-single-host-k3s-dev.md)
- Phase 1 implementation tracker: [docs/implementation/phase-1-implementation-tracker.md](docs/implementation/phase-1-implementation-tracker.md)
