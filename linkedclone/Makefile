THISDIR := $(notdir $(CURDIR))
PROJECT := $(THISDIR)

apply:
	terraform apply -auto-approve

init:
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
	terraform refresh && terraform output metadata

get-netboot-iso:
	wget http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/installer-amd64/current/images/netboot/mini.iso



