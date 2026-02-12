# em-infra — infrastructure (source of truth)

Canonical infrastructure for the project: Dockerfiles, Kubernetes manifests (Helm/Kustomize), Terraform modules and developer tooling (devcontainers, Skaffold/Tilt).

Quickstart (developer)

- Clone into your WSL distro or Linux machine (recommended).
- `docker compose up --build` → fast compose-first iteration.
- `skaffold dev -p dev` → k8s-parity local dev (requires kind/k3d).

See `docs/` for Windows-specific onboarding, GPU setup, and CI details.
