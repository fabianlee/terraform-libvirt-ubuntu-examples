# variables that can be overriden
variable "hostname" { default = "nestedkvm1" }
variable "domain" { default = "example.com" }
variable "ip_type" { default = "static" } # dhcp is other valid type
variable "memoryMB" { default = 1024*4 }
variable "cpu" { default = 2 }
variable "prefixIP" { default = "192.168.122" }
variable "octetIP" { default = "34" }

# 120Mb for additional data disk, formatted with xfs for project quota support
variable "diskBytes" { default = 1024*1024*120 }


# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

# fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "os_image" {
  name = "${var.hostname}-os_image"
  pool = "default"
  source = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Use CloudInit ISO to add ssh-key to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
          name = "${var.hostname}-commoninit.iso"
          pool = "default"
          user_data = data.template_file.user_data.rendered
          network_config = data.template_file.network_config.rendered
}
# extra data disk for xfs
resource "libvirt_volume" "disk_data1" {
  name           = "${var.hostname}-disk-xfs"
  pool           = "default"
  size           = var.diskBytes
  format         = "qcow2"
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
  vars = {
    domain = var.domain
    prefixIP = var.prefixIP
    octetIP = var.octetIP
  }
}


# Create the machine
resource "libvirt_domain" "domain-ubuntu" {
  # domain name in libvirt, not hostname
  name = "${var.hostname}-${var.prefixIP}.${var.octetIP}"
  memory = var.memoryMB
  vcpu = var.cpu
  cpu = { mode = "host-passthrough" }

  disk { volume_id = libvirt_volume.os_image.id }
  disk { volume_id = libvirt_volume.disk_data1.id }
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

output "ips" {
  #value = libvirt_domain.domain-ubuntu
  #value = libvirt_domain.domain-ubuntu.*.network_interface
  # show IP, run 'terraform refresh' if not populated
  value = libvirt_domain.domain-ubuntu.*.network_interface.0.addresses
}
