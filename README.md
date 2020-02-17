# terraform-libvirt provider for Ubuntu hosts

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
 
