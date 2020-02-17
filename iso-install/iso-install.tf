# variables that can be overriden
variable "hostname" { default = "iso-install" }
variable "domain" { default = "example.com" }
variable "memoryMB" { default = 1024*2 }
variable "cpu" { default = 2 }

# 15Gb for root filesystem
variable "rootdiskBytes" { default = 1024*1024*1024*15 }

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}


resource "libvirt_volume" "os_image" {
  name           = "${var.hostname}-root.qcow2"
  pool           = "default"
  size           = var.rootdiskBytes
  format         = "qcow2"
}


# Create the machine
resource "libvirt_domain" "domain-ubuntu" {
  name = var.hostname
  memory = var.memoryMB
  vcpu = var.cpu

  disk { file = pathexpand("~/Downloads/ubuntu-18.04.4-live-server-amd64.iso") }
  disk { volume_id = libvirt_volume.os_image.id }
  boot_device { dev = [ "cdrom", "hd", "network" ] }

  # uses DHCP
  network_interface {
       network_name = "default"
  }

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
