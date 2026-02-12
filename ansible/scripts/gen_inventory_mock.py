#!/usr/bin/env python3
"""
Simple validator / mock inventory generator that reads a terraform-style
`output -json` file and emits an Ansible INI hosts file for local testing.

This is NOT the production terraform inventory plugin; it's a small test helper.
"""
import json
import argparse
from pathlib import Path

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--tf-json", required=True, help="Path to terraform output JSON")
    p.add_argument("--out", default="ansible/inventory/hosts.ini", help="Output ini path")
    args = p.parse_args()

    data = json.loads(Path(args.tf_json).read_text())

    control = data.get("control_plane_ips", {}).get("value", [])
    workers = data.get("worker_ips", {}).get("value", [])
    gpus = data.get("gpu_worker_ips", {}).get("value", [])

    out_lines = []
    out_lines.append("[k3s_control]")
    for i, ip in enumerate(control, start=1):
        out_lines.append(f"control-{i} ansible_host={ip}")

    out_lines.append("")
    out_lines.append("[k3s_workers]")
    for i, ip in enumerate(workers, start=1):
        out_lines.append(f"worker-{i} ansible_host={ip}")

    out_lines.append("")
    out_lines.append("[k3s_gpu]")
    if gpus:
        for i, ip in enumerate(gpus, start=1):
            out_lines.append(f"gpu-{i} ansible_host={ip}")
    else:
        # keep group present but empty; add a comment entry so file remains valid
        out_lines.append("# no gpu hosts yet")

    Path(args.out).parent.mkdir(parents=True, exist_ok=True)
    Path(args.out).write_text("\n".join(out_lines) + "\n")
    print(f"Wrote inventory to {args.out}")

if __name__ == '__main__':
    main()
