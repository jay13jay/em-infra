#!/usr/bin/env python3
"""
Render a simple Ansible INI inventory from Terraform JSON output by extracting IP addresses.

Usage:
  python scripts/render_inventory_from_terraform.py terraform_output.json > ansible/inventory/bootstrap/generated.ini
Or pipe:
  terraform output -json | python scripts/render_inventory_from_terraform.py > ansible/inventory/bootstrap/generated.ini
"""
import sys
import json
import re

def extract_ips(obj):
    s = json.dumps(obj)
    return re.findall(r"\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b", s)

def main():
    if len(sys.argv) > 1:
        data = json.load(open(sys.argv[1]))
    else:
        data = json.load(sys.stdin)

    ips = extract_ips(data)
    ips = sorted(set(ips))

    print("[bootstrap]")
    for ip in ips:
        print(f"{ip} ansible_user=ubuntu")

if __name__ == '__main__':
    main()
