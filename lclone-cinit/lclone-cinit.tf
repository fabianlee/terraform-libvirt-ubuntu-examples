# variables that can be overriden
variable "hostname" { default = "lclone-cinit" }
variable "domain" { default = "example.com" }
variable "memoryMB" { default = 1024*2 }
variable "cpu" { default = 2 }
variable "ip_type" { default = "dhcp" }

# for root filesystem
variable "rootdiskBytes" { default = 1024*1024*1024*30 }

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

# Use CloudInit ISO to add ssh-key to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
          name = "${var.hostname}-commoninit.iso"
          pool = "default"
          user_data = data.template_file.user_data.rendered
          network_config = data.template_file.network_config.rendered
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname = var.hostname
    fqdn = "${var.hostname}.${var.domain}"
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config_${var.ip_type}.cfg")
}


# create a disk with a parent backing file
resource "libvirt_volume" "os_image" {
  name = "${var.hostname}.qcow2"
  
  # can specify size larger than backing disk
  # but would need to be extended at OS level to be recognized
  #size = var.rootdiskBytes

  # parent disk
  base_volume_pool = "default"
  base_volume_name = "iso-install-root.qcow2"
}  


# Create the machine
resource "libvirt_domain" "domain-ubuntu" {
  name = var.hostname
  memory = var.memoryMB
  vcpu = var.cpu

  disk { volume_id = libvirt_volume.os_image.id }

  # uses DHCP
  network_interface {
       network_name = "default"
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  # IMPORTANT
  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}

terraform { 
  required_version = ">= 0.12"
}

output "metadata" {
  # run 'terraform refresh' if not populated
  value = libvirt_domain.domain-ubuntu
}
