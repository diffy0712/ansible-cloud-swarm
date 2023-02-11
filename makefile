include .env
export

.PHONY: lint
lint: ## Run yamllint and ansible-lint on all of the files
	make lintf f=./	

.PHONY: lintf
lintf: ## Run yamllint and ansible-lint on a path
	@[ "${f}" ] || ( echo "f is not set. available: ./, tasks/main.yml etc..."; exit 1 )
	yamllint ${f}
	ansible-lint ${f}

.PHONY: lintw
lintw: ## Start watching for file changes and lint them.
	onchange './**/*.yml' -e ./gitlab-ci.yml -- make lintf f='./{{file}}'

.PHONY: test
test: ## Run molecule tests on default platform
	molecule test

.PHONY: hooks
hooks: ## Copy git hooks (might need sudo to copy to .git/hooks)
	npm install -g @commitlint/{config-conventional,cli}
	cp bin/hooks/commit-msg.sh .git/hooks/commit-msg
	chmod +x .git/hooks/commit-msg

.PHONY: idep ## Install all dependencies (roles and collections)
idep: iroles icollections

.PHONY: udep ## Update all dependencies (roles and collections)
udep: uroles ucollections

.PHONY: iroles ## Install all roles
iroles: 
		ansible-galaxy install -r requirements.roles.yml -p vendor/roles

.PHONY: uroles ## Update all roles
uroles:
		ansible-galaxy install -r requirements.roles.yml -p vendor/roles --force

.PHONY: icollections ## Install all collections
icollections:
		ansible-galaxy collection install -r requirements.collections.yml -p vendor/collections

.PHONY: ucollections ## Update all collections
ucollections:
		ansible-galaxy collection install -r requirements.collections.yml -p vendor/collections --force

.PHONY: prepare
prepare: ## Prepare the server(s) for maintainance of a host or a group of hosts. Select a host/group from inventory. Use s variable to add args. example: make prepare host=test s="-tag test"
		@[ "${host}" ] || ( echo "host is not set. Please select a host or a group from inventory"; exit 1 )
		ansible-playbook -i $(inventory_file) --vault-password-file $(inventory_vault_pass) prepare.yml --limit ${host} --extra-vars "inventory_path=$(inventory_path)" ${s}

.PHONY: maintain
maintain: ## Run maintainance playbook on the server(s) of a host or a group of hosts. Select a host/group from inventory. Use s variable to add args. example: make maintain host=test s="-tag test"
		@[ "${host}" ] || ( echo "host is not set. Please select a host or a group from inventory"; exit 1 )
		ansible-playbook -i $(inventory_file) --vault-password-file $(inventory_vault_pass) maintain.yml --limit ${host} --extra-vars "inventory_path=$(inventory_path)" ${s}

.PHONY: invlist
invlist: ## List variables from inventory
		ansible-inventory -i $(inventory_file) --vault-password-file $(inventory_vault_pass) --extra-vars "inventory_path=$(inventory_path)" --list


.PHONY: help
help: ## Display this help message
	@cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
