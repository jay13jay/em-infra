ARG BASE_IMAGE=golang:latest
FROM ${BASE_IMAGE}

ARG TERRAFORM_VERSION=1.14.4

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    wget \
    ansible \
  && rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN wget -qO /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && unzip /tmp/terraform.zip -d /usr/local/bin \
  && chmod +x /usr/local/bin/terraform \
  && rm /tmp/terraform.zip

RUN terraform --version || true

WORKDIR /workspaces/em-infra
