# terraform-libvirt provider for Ubuntu hosts

Described in blog entry: https://fabianlee.org/2020/02/22/kvm-terraform-and-cloud-init-to-create-local-kvm-resources

## cloud-init
* simple - simple host with DHCP address
* staticip - host with static IP address
* datadisks - host with 2 additional data disks, one xfs and the other ext4 
* nestedkvm - passes through cpu features, installed docker and kvm with data drive
* lclone-cinit - linked clone using backing file with cloud-init for customization

## traditional install media
* net-install - Ubuntu net installer
* iso-install - Ubuntu fat ISO installer
* linkedclone - linked clone using backing file from ISO installer

## Usage

Go into any of the example directories:

* make create-keypair
* make init
* make apply
 
