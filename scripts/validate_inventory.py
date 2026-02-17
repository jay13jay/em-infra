#!/usr/bin/env python3
"""Simple inventory validator with optional jsonschema support.

Checks `inventory/dev/cluster.yaml` and `inventory/dev/nodes.yaml` against
`inventory.schema.json`. If `jsonschema` is available it will be used; otherwise
basic required-key checks run as a fallback.
"""
import json
import os
import sys

try:
    import yaml
except Exception:
    print("Missing dependency: PyYAML is required (pip install pyyaml)")
    sys.exit(2)

SCHEMA_PATH = os.path.join(os.path.dirname(__file__), '..', 'inventory.schema.json')
CLUSTER_YAML = os.path.join(os.path.dirname(__file__), '..', 'inventory', 'dev', 'cluster.yaml')
NODES_YAML = os.path.join(os.path.dirname(__file__), '..', 'inventory', 'dev', 'nodes.yaml')


def load_json(path):
    with open(path, 'r') as f:
        return json.load(f)


def load_yaml(path):
    with open(path, 'r') as f:
        return yaml.safe_load(f)


def basic_check_cluster(obj):
    req = ["cluster_name", "environment", "talos_version", "kubernetes_version", "network"]
    missing = [k for k in req if k not in obj]
    if missing:
        return False, f"cluster.yaml missing keys: {missing}"
    if not isinstance(obj.get('network'), dict):
        return False, "cluster.yaml: network must be an object"
    return True, "cluster OK"


def basic_check_nodes(obj):
    if 'nodes' not in obj:
        return False, "nodes.yaml missing top-level 'nodes'"
    if not isinstance(obj['nodes'], list):
        return False, "nodes.yaml: 'nodes' must be a list"
    for i, n in enumerate(obj['nodes']):
        for k in ('name', 'ip', 'roles'):
            if k not in n:
                return False, f"nodes.yaml: node[{i}] missing '{k}'"
    return True, "nodes OK"


def main():
    schema = None
    if os.path.exists(SCHEMA_PATH):
        try:
            schema = load_json(SCHEMA_PATH)
        except Exception as e:
            print(f"Failed loading schema: {e}")

    cluster = load_yaml(CLUSTER_YAML)
    nodes = load_yaml(NODES_YAML)

    # Try using jsonschema if available
    try:
        import jsonschema
        if schema:
            jsonschema.validate(cluster, schema.get('definitions', {}).get('cluster', {}))
            jsonschema.validate(nodes, schema.get('definitions', {}).get('nodes', {}))
        print("Validation: OK (jsonschema)")
        return 0
    except Exception:
        # Fallback
        ok, msg = basic_check_cluster(cluster)
        if not ok:
            print("Validation failed:", msg)
            return 3
        ok, msg = basic_check_nodes(nodes)
        if not ok:
            print("Validation failed:", msg)
            return 4
        print("Validation: OK (basic checks)")
        return 0


if __name__ == '__main__':
    sys.exit(main())
