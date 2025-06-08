# Use bash for all shell commands
SHELL := /bin/bash

.PHONY: help
help: ## Shows this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: ## Sets up the application on Fly.io for the first time
	@echo "--- Setting up Fly.io App ---"
	@if ! command -v flyctl &> /dev/null; then \
		echo "ERROR: flyctl is not installed. Please install from https://fly.io/docs/hands-on/install-flyctl/"; \
		exit 1; \
	fi
	@if ! flyctl status &> /dev/null; then flyctl launch --copy-config --no-deploy; fi
	@if ! flyctl postgres status &> /dev/null; then flyctl postgres create; fi
	@if ! flyctl secrets list | grep -q "RAILS_MASTER_KEY"; then \
		echo "Generating and setting RAILS_MASTER_KEY..."; \
		flyctl secrets set RAILS_MASTER_KEY=$$(openssl rand -hex 64); \
	else \
		echo "RAILS_MASTER_KEY already exists. Skipping."; \
	fi
	@echo "✅ Fly.io setup is complete."
	@echo "Now you can deploy with: make deploy"

.PHONY: deploy
deploy: ## Deploys the application to Fly.io
	@echo "--- Deploying to Fly.io ---"
	flyctl deploy

.PHONY: create-admin
create-admin: ## Creates the initial admin user using a dedicated setup script.
	@# This executes the setup script. All logic is now inside that file.
	@bash ./client-scripts/setup-admin.sh