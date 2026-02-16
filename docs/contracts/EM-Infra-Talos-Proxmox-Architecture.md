# EM-Infra Talos Architecture — Proxmox Immutable Kubernetes Cluster

**Owner:** Solo developer + AI assistants  
**Scope:** Talos-based Kubernetes cluster automation on single Proxmox host  
**Status:** Design finalized → implementation ready  
**Applies to:** Dev + future prod topology  

---

# Navigation

- Docs index: [docs/README.md](../README.md)
- Architecture contract (this document): [docs/contracts/EM-Infra-Talos-Proxmox-Architecture.md](./EM-Infra-Talos-Proxmox-Architecture.md)
- Delivery sequencing roadmap: [docs/planning/infra-roadmap-single-host-k3s-dev.md](../planning/infra-roadmap-single-host-k3s-dev.md)

---

# Tasking Alignment

- This document defines the canonical technical architecture and ownership boundaries.
- The roadmap defines sequencing, timeline, and execution checkpoints.
- If roadmap task wording conflicts with architectural boundaries here, this document takes precedence.

---

# Executive Summary

This document defines the **Talos-native infrastructure architecture** for Kubernetes clusters on Proxmox.

It replaces traditional:

- SSH node configuration
- mutable VM OS images
- Ansible node provisioning

with a modern immutable model:

- Talos machine configs define node state
- Terraform defines VM lifecycle
- Kubernetes defines workload state
- Ansible orchestrates generation & bootstrap only

## Primary Goals

- Deterministic cluster bring-up/tear-down
- Immutable node OS with zero drift
- Single-source cluster inventory
- Full reproducibility on one Proxmox host
- Clean path to multi-cluster later

---

# Architecture Overview

## Layer Responsibilities

### Proxmox
- VM lifecycle
- storage + network
- hypervisor monitoring
- template cloning

### Terraform
- Talos VM provisioning
- VM hardware config
- network attachment
- Talos machine config injection

### Talos
- Node OS configuration
- Kubernetes runtime
- etcd membership
- kubelet lifecycle
- node networking

### Kubernetes
- workloads
- storage classes
- ingress
- observability stack
- cluster addons

### Ansible
- Generate Talos machine configs
- Orchestrate bootstrap order
- Retrieve kubeconfig
- Install post-cluster addons

---

# Core Design Principles

## 1. Nodes are Immutable

- No SSH
- No package manager
- No config drift
- Replace instead of repair

## 2. Inventory = Cluster Intent

Inventory YAML defines:

- cluster topology
- node roles
- hardware sizing
- IP layout
- Talos + Kubernetes versions

It is the **single source of truth** for:

- Terraform
- Talos configs
- Bootstrap orchestration

## 3. Terraform Owns Infrastructure Only

Terraform never configures nodes.

It only:

- clones Talos VMs
- injects machine config
- starts nodes

## 4. Talos Owns Node State

Talos machine config fully defines:

- kubelet
- container runtime
- networking
- disks
- cluster join role

---

# Repository Structure

```
infra/
├── docker/
│   ├── ansible.Dockerfile
│   ├── terraform.Dockerfile
│   └── docker-compose.yml
│
├── inventory/
│   ├── dev/
│   │   ├── cluster.yaml
│   │   ├── nodes.yaml
│   │   └── secrets.sops.yaml
│   └── prod/
│
├── terraform/
│   ├── modules/
│   │   └── proxmox-talos-vm/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── talos-machines.auto.tfvars.json
│
├── ansible/
│   ├── playbooks/
│   │   ├── talos-gen-config.yml
│   │   ├── talos-bootstrap.yml
│   │   └── kube-post.yml
│
└── talos/
    ├── patches/
    └── generated/
```

---

# Inventory Model

## cluster.yaml

Defines global cluster properties.

```
cluster_name: dev
talos_version: v1.8.2
kubernetes_version: v1.30.1

network:
  pod_cidr: 10.244.0.0/16
  svc_cidr: 10.96.0.0/12

proxmox:
  node: pve1
  datastore: local-lvm
  bridge: vmbr0
```

---

## nodes.yaml

Defines topology and sizing.

```
controlplane:
  - name: dev-cp-1
    ip: 10.0.10.11
    cpu: 4
    ram: 8192
    disk: 40G

workers:
  - name: dev-wk-1
    ip: 10.0.10.21
    cpu: 4
    ram: 8192
    disk: 60G
```

---

# Automation Workflow

## Phase 1 — Generate Talos Configs

Ansible reads inventory and generates:

- cluster config
- per-node machine configs
- Terraform variable file

Command:

```
docker compose run ansible ansible-playbook ansible/playbooks/talos-gen-config.yml
```

Outputs:

```
talos/generated/<node>.yaml
terraform/dev/talos-machines.auto.tfvars.json
```

---

## Phase 2 — Provision Talos VMs

Terraform:

- clones Talos template
- applies hardware sizing
- injects machine config
- starts VMs

Command:

```
docker compose run terraform terraform -chdir=terraform/dev apply
```

---

## Phase 3 — Bootstrap Cluster

Ansible orchestrates Talos bootstrap:

- apply config to first controlplane
- bootstrap etcd
- join remaining nodes
- fetch kubeconfig

Command:

```
docker compose run ansible ansible-playbook ansible/playbooks/talos-bootstrap.yml
```

---

## Phase 4 — Install Cluster Addons

Post-cluster configuration:

- CNI (if custom)
- storage class
- ingress
- metrics
- GitOps agent

Command:

```
docker compose run ansible ansible-playbook ansible/playbooks/kube-post.yml
```

---

# End‑to‑End Bring‑Up

```
docker compose run ansible ansible-playbook ansible/playbooks/talos-gen-config.yml
docker compose run terraform terraform -chdir=terraform/dev apply
docker compose run ansible ansible-playbook ansible/playbooks/talos-bootstrap.yml
docker compose run ansible ansible-playbook ansible/playbooks/kube-post.yml
```

---

# Proxmox Integration Notes

## Guest Agent

Talos does not support qemu-guest-agent.

Implications:

- No IP reporting in UI
- No FS freeze
- No guest exec

Mitigation:

- DHCP reservation per MAC
- Talos API for node control
- Kubernetes metrics for monitoring

---

## Monitoring Model

### Proxmox provides

- CPU
- RAM
- disk IO
- network IO
- VM state

### Kubernetes provides

- node metrics
- pod metrics
- filesystem usage
- kubelet health

---

# Talos VM Template Strategy

## Template Creation

1. Create VM
2. Attach Talos ISO
3. Install to disk
4. Convert to template

Template contains:

- Talos OS only
- no machine config
- no cluster identity

---

## Clone Strategy

Each node clone receives:

- CPU/RAM/disk sizing
- static MAC
- machine config

Nodes are cattle and replaceable.

---

# Implementation Checklist

## Repo Foundations

- [ ] Create directory structure
- [ ] Add dockerfiles for ansible/terraform
- [ ] Add docker-compose toolchain
- [ ] Add inventory/dev structure
- [ ] Add talos/generated directory
- [ ] Add terraform/dev workspace

---

## Inventory

- [ ] Define cluster.yaml schema
- [ ] Define nodes.yaml schema
- [ ] Create dev inventory files
- [ ] Validate YAML parsing in Ansible

---

## Talos Config Generation

- [ ] Implement talos-gen-config playbook
- [ ] Integrate talosctl gen config
- [ ] Support controlplane/worker roles
- [ ] Write per-node machine configs
- [ ] Export terraform tfvars JSON
- [ ] Support config patches

---

## Terraform Talos Module

- [ ] Create proxmox-talos-vm module
- [ ] Inputs: cpu/ram/disk/ip/config
- [ ] Clone Talos template
- [ ] Attach disk
- [ ] Inject machine config ISO
- [ ] Start VM
- [ ] Output node IDs

---

## Bootstrap Automation

- [ ] talos-bootstrap playbook
- [ ] Apply first controlplane config
- [ ] Wait for Talos API
- [ ] Run talosctl bootstrap
- [ ] Join remaining nodes
- [ ] Retrieve kubeconfig
- [ ] Verify node readiness

---

## Post‑Cluster Automation

- [ ] kube-post playbook
- [ ] Install metrics stack
- [ ] Install ingress
- [ ] Install storage class
- [ ] Install GitOps agent
- [ ] Verify cluster health

---

## Proxmox Template

- [ ] Create Talos VM
- [ ] Install Talos disk image
- [ ] Convert to template
- [ ] Document template ID
- [ ] Validate clone workflow

---

# Operational Runbook

## Recreate Cluster

```
terraform destroy
terraform apply
talos bootstrap
addons install
```

---

## Replace Node

```
terraform taint vm
terraform apply
talos join
```

---

## Scale Workers

1. Add node to nodes.yaml  
2. Regenerate configs  
3. Terraform apply  
4. Talos join  

---

# Success Criteria

- Cluster reproducible from inventory
- Nodes immutable and replaceable
- No SSH or manual config
- Terraform idempotent
- Talos bootstrap automated
- Kubernetes addons automated

---

# Future Extensions

- Multi‑cluster inventory
- HA controlplane
- GitOps bootstrap auto
- Talos image pipeline
- Remote Terraform backend
