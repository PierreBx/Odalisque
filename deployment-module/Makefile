# Makefile for deployment module

.PHONY: help setup check deploy test health lint clean

help:
	@echo "Deployment Module Commands"
	@echo "=========================="
	@echo "make setup    - Initial setup and configuration"
	@echo "make check    - Run playbook in check mode (dry-run)"
	@echo "make deploy   - Deploy configuration to server"
	@echo "make test     - Test connection to server"
	@echo "make health   - Run health check on server"
	@echo "make lint     - Lint Ansible files"
	@echo "make clean    - Clean temporary files"

setup:
	@./scripts/setup.sh

check:
	@ansible-playbook playbooks/configure_server.yml --check

deploy:
	@./scripts/deploy.sh

test:
	@echo "Testing connection to Raspberry Pi..."
	@ansible all -m ping

health:
	@./scripts/health_check.sh

lint:
	@echo "Linting Ansible files..."
	@ansible-lint playbooks/*.yml || true

clean:
	@echo "Cleaning temporary files..."
	@rm -f ansible.log
	@rm -f **/*.retry
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -delete
	@echo "Clean complete!"
