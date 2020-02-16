OWNER := fabianlee
PROJECT := nestedkvm
IP := 192.168.122.34
THISDIR := $(notdir $(CURDIR))

## recreate terraform resources
rebuild: destroy build

destroy:
	terraform destroy -auto-approve

build:
	terraform apply -auto-approve -var-file=$(PROJECT).tfvars

## validate syntax of cloud_init
validate-cloud-config:
	cloud-init devel schema --config-file cloud_init.cfg

## ssh into VM, unique after each rebuild so clear known_hosts
ssh:
	ssh-keygen -f ~/.ssh/known_hosts -R $(IP)
	ssh-keyscan "$(IP)" >> ~/.ssh/known_hosts
	ssh ubuntu@$(IP) -i id_rsa

## create public/private keypair for ssh
create-ssh:
	@echo "THIDIR=$(THISDIR)"
	ssh-keygen -t rsa -b 4096 -f id_rsa -C $(PROJECT) -N "" -q

## IP address not immediately available
get-ip:
	terraform refresh