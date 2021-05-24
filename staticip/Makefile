THISDIR := $(notdir $(CURDIR))
PROJECT := $(THISDIR)
IP := 192.168.122.31
TERRAFORM := terraform

apply:
	$(TERRAFORM) apply -auto-approve -var-file=$(PROJECT).tfvars

init:
	$(TERRAFORM) init

## recreate terraform resources
rebuild: destroy apply

destroy:
	$(TERRAFORM) destroy -auto-approve

## ssh into VM, unique after each rebuild so refresh known_hosts
ssh:
	ssh-keygen -f ~/.ssh/known_hosts -R $(IP)
	ssh-keyscan "$(IP)" >> ~/.ssh/known_hosts
	ssh ubuntu@$(IP) -i id_rsa

## create public/private keypair for ssh
create-keypair:
	@echo "THISDIR=$(THISDIR)"
	ssh-keygen -t rsa -b 4096 -f id_rsa -C $(PROJECT) -N "" -q

metadata:
	$(TERRAFORM) refresh && $(TERRAFORM) output

## validate syntax of cloud_init
validate-cloud-config:
	cloud-init devel schema --config-file cloud_init.cfg
