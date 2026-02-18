# ssh_keys role

Generates and manages **cluster-scoped SSH keypairs** for automation workflows.

This role is designed to avoid reusing long-lived personal SSH keys by creating a dedicated keypair per cluster/environment.

## Behavior

- Creates key directory: `{{ playbook_dir }}/../.keys/<cluster_name>/`
- Generates keypair when missing (`ed25519` by default)
- Supports rotation with `ssh_keys_force_regenerate: true`
- Exposes facts:
  - `ssh_cluster_private_key_path`
  - `ssh_cluster_public_key_path`
  - `ssh_cluster_public_key`

## Key variables

- `ssh_keys_cluster_name` (default: `cluster_name` or `env_name` or `em-dev`)
- `ssh_keys_type` (`ed25519` or `rsa`, default `ed25519`)
- `ssh_keys_force_regenerate` (default `false`)

## Example usage

```yaml
- hosts: localhost
  connection: local
  gather_facts: false
  roles:
    - role: ssh_keys
  vars:
    ssh_keys_cluster_name: k3s-dev
```

Then consume in later tasks/roles:

```yaml
build_ssh_pubkey: "{{ ssh_cluster_public_key }}"
```
