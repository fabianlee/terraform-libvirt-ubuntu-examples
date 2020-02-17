THISDIR := $(notdir $(CURDIR))
PROJECT := $(THISDIR)


apply: ## applies this
	terraform apply -auto-approve

init: ## first time
	terraform init

## recreate terraform resources
rebuild: destroy apply

destroy:
	terraform destroy -auto-approve

## create public/private keypair for ssh
create-keypair:
	@echo "THISDIR=$(THISDIR)"
	ssh-keygen -t rsa -b 4096 -f id_rsa -C $(PROJECT) -N "" -q

metadata:
	terraform refresh && terraform output ips

get-iso:
	wget -P ~/Downloads http://releases.ubuntu.com/18.04/ubuntu-18.04.4-live-server-amd64.iso

## list make targets
## https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'


