ARG BASE_IMAGE=mcr.microsoft.com/devcontainers/go:1-bullseye
FROM ${BASE_IMAGE}

ARG TERRAFORM_VERSION=1.14.4

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    locales \
    ca-certificates \
    curl \
    unzip \
    wget \
    ansible \
  && locale-gen en_US.UTF-8 \
  && update-locale LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install Terraform
RUN wget -qO /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && unzip /tmp/terraform.zip -d /usr/local/bin \
  && chmod +x /usr/local/bin/terraform \
  && rm /tmp/terraform.zip

RUN terraform --version || true

WORKDIR /workspaces/em-infra
