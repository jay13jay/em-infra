# Minimal image with ansible and proxmox-ansible playbook checked out
FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       git sshpass openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install ansible-core; keep exact pin aligned with ansible/requirements.txt
RUN pip install --no-cache-dir "ansible-core==2.20.2" passlib

# Install required collections for proxmox-ansible (community.general for archive, ansible.posix for authorized_key, etc.)
RUN ansible-galaxy collection install community.general ansible.posix --force

# Clone proxmox-ansible into /workspace/proxmox-ansible
ARG PROXMOX_ANSIBLE_REPO=https://github.com/yokozu777/proxmox-ansible.git
ARG PROXMOX_ANSIBLE_REF=main
RUN git clone --branch "$PROXMOX_ANSIBLE_REF" "$PROXMOX_ANSIBLE_REPO" /workspace/proxmox-ansible

WORKDIR /workspace/proxmox-ansible

# Default command: show available playbooks
CMD ["ls", "-1"]
