# GitHub Copilot Instructions for em-infra

## Project Overview

This is an infrastructure-as-code repository for managing Kubernetes clusters on Proxmox using a modern immutable infrastructure approach. The project uses:

- **Terraform** for VM lifecycle management
- **Ansible** for orchestration and bootstrap workflows
- **Talos Linux** for immutable Kubernetes nodes
- **Kubernetes (k3s/Talos)** for workload orchestration
- **Docker/Compose** for local development

## Repository Structure

- `/terraform/` - Terraform modules and environments for VM provisioning
- `/ansible/` - Ansible playbooks and roles for orchestration
- `/k8s/` - Kubernetes manifests (Helm/Kustomize)
- `/services/` - Service definitions and Dockerfiles
- `/inventory/` - Infrastructure inventory files (YAML)
- `/docs/` - Comprehensive documentation hierarchy
- `/scripts/` - Utility scripts for automation
- `/tools/` - Developer tooling

## Architecture Principles

### Immutable Infrastructure
- Talos machine configs define node state (not SSH/mutable VMs)
- Terraform manages VM lifecycle only
- Ansible orchestrates generation and bootstrap workflows
- Zero configuration drift through immutability

### Single Source of Truth
- Inventory files in `/inventory/` are canonical
- All infrastructure state derives from inventory
- Documentation in `/docs/` is the authoritative reference

## Coding Standards

### Terraform
- Use explicit provider version constraints in `versions.tf`
- Follow module structure: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
- Use descriptive variable names with validation rules
- Document all variables and outputs
- Keep environments in separate directories under `/terraform/environments/`

### Ansible
- Place playbooks in `/ansible/playbooks/`
- Use roles in `/ansible/roles/` for reusable logic
- Follow naming convention: `role_name` with underscores
- Use meaningful tags for selective execution
- Document playbook purpose and required variables

### Kubernetes
- Use declarative YAML manifests
- Follow namespace isolation patterns
- Include resource limits and requests
- Document custom configurations

### Infrastructure Files
- Use YAML for inventory and configuration files
- Follow JSON schema validation where provided (see `inventory.schema.json`, `schema.json`)
- Maintain consistent naming: kebab-case for files, snake_case for variables

## Documentation Guidelines

### Documentation Hierarchy
1. **Contract docs** (`docs/contracts/`) - Architecture and boundaries
2. **Planning docs** (`docs/planning/`) - Roadmaps and milestones
3. **Execution docs** (`docs/implementation/`) - Phase trackers and task docs
4. **Guide docs** (`docs/guides/`) - Onboarding and runbooks

### Documentation Rules
- Every major document must include a Navigation section linking to:
  - Documentation index (`docs/README.md`)
  - Architecture contract
  - Active roadmap
- Use relative links for cross-references
- Prefix phase trackers as `phase-<n>-...`
- Use task document template from `docs/implementation/templates/task-doc-template.md`

### AI Assistant Workflow (from docs/README.md)
When working on implementation tasks:
1. Review architecture contract, roadmap, and active tracker
2. Generate task docs using the template
3. Validate against architecture boundaries
4. Create atomic execution plans
5. Document validation results in execution logs

## Best Practices

### Infrastructure Changes
- Always validate Terraform plans before applying
- Test Ansible playbooks in dev environment first
- Verify idempotency of automation scripts
- Document infrastructure dependencies and prerequisites

### Git Workflow
- Use descriptive commit messages
- Keep changes atomic and focused
- Reference issue numbers in commits when applicable
- Don't commit sensitive data (credentials, keys)

### File Management
- Exclude build artifacts via `.gitignore`
- Keep temporary files in `/tmp/` directory
- Use `.devcontainer/` for development environment configuration

### Validation
- Run `terraform validate` and `terraform fmt` for Terraform changes
- Use `ansible-lint` for playbook validation (if configured)
- Verify YAML syntax for configuration files
- Check JSON schema compliance for inventory files

## Common Operations

### Local Development
- Use `docker compose up --build` for fast iteration
- Use `skaffold dev -p dev` for k8s-parity local development (requires kind/k3d)

### Infrastructure Deployment
- Review active phase tracker in `docs/implementation/phase-*/`
- Follow task documentation for specific implementations
- Validate against architecture contract before major changes

## When Helping with Code

### Prioritize
1. Maintain immutability principles (no SSH configuration, no mutable VMs)
2. Follow existing patterns in the codebase
3. Update documentation when changing architecture or workflows
4. Ensure changes align with the architecture contract
5. Validate against existing schemas

### Avoid
- Don't add mutable VM configuration patterns
- Don't bypass inventory as source of truth
- Don't modify architecture without updating contract docs
- Don't skip validation steps
- Don't introduce configuration drift mechanisms

## Key Documentation to Reference

- Architecture Contract: `docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md`
- Documentation Index: `docs/README.md`
- Active Roadmap: Check `docs/planning/` for current roadmap
- Phase Trackers: Check `docs/implementation/phase-*/` for active phase

## Testing and Validation

- Infrastructure changes should be validated in dev environment first
- Document test results in phase tracker execution logs
- Verify idempotency of all automation
- Test rollback procedures when implementing new features

## Security Considerations

- Never commit secrets or credentials
- Use secure parameter passing for sensitive data
- Follow least privilege principles in access controls
- Document security implications of infrastructure changes
