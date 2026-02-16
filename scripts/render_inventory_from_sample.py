#!/usr/bin/env python3
import json
from pathlib import Path

sample = Path('terraform/environments/k3s-dev/sample_outputs.json')
if not sample.exists():
    print('sample_outputs.json not found')
    raise SystemExit(1)

data = json.loads(sample.read_text())

# Terraform sample outputs have structure {"control_plane_ips": {"value": [..]}}
outputs = {k: v.get('value') if isinstance(v, dict) else v for k, v in data.items()}

inventory = {"_meta": {"hostvars": {}}, "all": {"children": []}}

mapping = {
    'k3s_control': 'control_plane_ips',
    'k3s_workers': 'worker_ips',
    'k3s_gpu': 'gpu_worker_ips',
}

for group, out in mapping.items():
    ips = outputs.get(out) or []
    inventory[group] = {"hosts": ips}
    inventory['all']['children'].append(group)

print(json.dumps(inventory, indent=2))
