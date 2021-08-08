THISDIR := $(notdir $(CURDIR))
PROJECT := $(THISDIR)
TF := terraform

apply: init 
	$(TF) apply -auto-approve

init: create-keypair
	# skips init if .terraform directory already exists
	[ -d .$(TF) ] || $(TF) init

destroy:
	$(TF) destroy -auto-approve
	./clean-known-hosts.sh
	#rm terraform.tfstate*

## create public/private keypair for ssh
create-keypair:
	# skips if file already exists
	[ -f id_rsa ] || ssh-keygen -t rsa -b 4096 -f id_rsa -C $(PROJECT) -N "" -q

refresh:
	$(TF) refresh
	$(TF) output

## validate syntax of cloud_init
validate-cloud-config:
	cloud-init devel schema --config-file cloud_init.cfg
