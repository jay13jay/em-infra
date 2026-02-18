SHELL := /usr/bin/env bash

TF_IMAGE ?= hashicorp/terraform:1.14.5
TF_ENV_DIR ?= terraform/environments/k3s-dev
TF_VARS ?= terraform.tfvars

.PHONY: help tf-init tf-validate tf-plan tf-plan-fast tf-apply tf-destroy tf-output tf-output-json tf-output-contract tf-state-list tf-backup-state tf-gate

help:
	@echo "Common EM-Infra runbooks (Dockerized Terraform)"
	@echo "  make tf-init            - terraform init for $(TF_ENV_DIR)"
	@echo "  make tf-validate        - terraform validate"
	@echo "  make tf-plan            - terraform plan (-compact-warnings)"
	@echo "  make tf-plan-fast       - terraform plan -refresh=false (-compact-warnings)"
	@echo "  make tf-apply           - terraform apply -auto-approve (-compact-warnings)"
	@echo "  make tf-destroy         - terraform destroy -auto-approve (-compact-warnings)"
	@echo "  make tf-output          - terraform output"
	@echo "  make tf-output-json     - terraform output -json"
	@echo "  make tf-output-contract - terraform output -json talos_bootstrap_contract"
	@echo "  make tf-state-list      - terraform state list"
	@echo "  make tf-backup-state    - snapshot terraform.tfstate with timestamp"
	@echo "  make tf-gate            - init, validate, plan, apply, plan"
	@echo ""
	@echo "Overrides:"
	@echo "  TF_ENV_DIR=terraform/environments/k3s-dev"
	@echo "  TF_VARS=terraform.tfvars"
	@echo "  TF_IMAGE=hashicorp/terraform:1.14.5"
	@echo ""
	@echo "Example:"
	@echo "  make tf-plan"

# Internal helper macro for Windows + Git Bash path semantics.
define TF_RUN
MSYS_NO_PATHCONV=1 docker run --rm \
	-v "$$(pwd -W):/workspace" \
	-w /workspace/$(TF_ENV_DIR) \
	$(TF_IMAGE) $(1)
endef

tf-init:
	@$(call TF_RUN,init -input=false)

tf-validate:
	@$(call TF_RUN,validate)

tf-plan:
	@$(call TF_RUN,plan -compact-warnings -var-file=$(TF_VARS))

tf-plan-fast:
	@$(call TF_RUN,plan -compact-warnings -refresh=false -var-file=$(TF_VARS))

tf-apply:
	@$(call TF_RUN,apply -compact-warnings -auto-approve -var-file=$(TF_VARS))

tf-destroy:
	@$(call TF_RUN,destroy -compact-warnings -auto-approve -var-file=$(TF_VARS))

tf-output:
	@$(call TF_RUN,output)

tf-output-json:
	@$(call TF_RUN,output -json)

tf-output-contract:
	@$(call TF_RUN,output -json talos_bootstrap_contract)

tf-state-list:
	@$(call TF_RUN,state list)

tf-backup-state:
	@mkdir -p $(TF_ENV_DIR)/state-backups
	@ts=$$(date +%Y%m%d-%H%M%S); \
	cp $(TF_ENV_DIR)/terraform.tfstate $(TF_ENV_DIR)/state-backups/terraform.tfstate.$$ts; \
	echo "Backed up state to $(TF_ENV_DIR)/state-backups/terraform.tfstate.$$ts"

tf-gate:
	@$(MAKE) tf-init
	@$(MAKE) tf-validate
	@$(MAKE) tf-plan
	@$(MAKE) tf-apply
	@$(MAKE) tf-plan
