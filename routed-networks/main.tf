# example of creating routed networks and placing vms on each
#
# documentation: 
#   https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/network 

# list of hosts to be created, use 'for_each' on relevant resources
locals {
  seedvm = {
    "routed1" = { os_code_name = "focal", network = "routed140", prefixIP = "192.168.140", octetIP = "10", vcpu=2, memoryMB=1024*2 },
    "routed2" = { os_code_name = "focal", network = "routed141", prefixIP = "192.168.141", octetIP = "10", vcpu=2, memoryMB=1024*2 }
  }
  networks = {
    "routed140" = { mode="route", address="192.168.140.0/24", domain="home.lab", dns_forwarder="127.0.0.1"},
    "routed141" = { mode="route", address="192.168.141.0/24", domain="home.lab", dns_forwarder="127.0.0.1"},
  }
}

resource "libvirt_network" "routed" {
  for_each = local.networks
  name = each.key
  # nat|none|route|bridge
  mode = each.value.mode
  addresses = [ each.value.address ]

  domain = each.value.domain
  dns {
    enabled = true
    local_only = false
    forwarders { address= each.value.dns_forwarder }
  }
  dhcp { enabled = false }
  autostart = true
}


# fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "os_image" {
  for_each = local.seedvm

  name = "${each.key}.qcow2"
  pool = var.diskPool
  source = "https://cloud-images.ubuntu.com/${each.value.os_code_name}/current/${each.value.os_code_name}-server-cloudimg-amd64${ each.value.os_code_name == "xenial" ? "-disk1":"" }.img"
  format = "qcow2"
}


# Use CloudInit ISO to add ssh-key to the instance
resource "libvirt_cloudinit_disk" "cloudinit" {
  for_each = local.seedvm

  name = "${each.key}-cloudinit.iso"
  pool = var.diskPool
  user_data = data.template_file.user_data[each.key].rendered
  network_config = data.template_file.network_config[each.key].rendered
}


data "template_file" "user_data" {
  for_each = local.seedvm

  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname = each.key
    fqdn = "${each.key}.${var.dns_domain}"
    password = var.password
  }
}

data "template_file" "network_config" {
  for_each = local.seedvm

  template = file("${path.module}/network_config_${var.ip_type}.cfg")
  vars = {
    domain = var.dns_domain
    prefixIP = each.value.prefixIP
    octetIP = each.value.octetIP
  }
}


# Create the machine
resource "libvirt_domain" "domain-ubuntu" {
  for_each = local.seedvm

  # domain name in libvirt, not hostname
  name = "${each.key}-${each.value.prefixIP}.${each.value.octetIP}"
  memory = each.value.memoryMB
  vcpu = each.value.vcpu

  disk { volume_id = libvirt_volume.os_image[each.key].id }

  network_interface {
       network_name = "${each.value.network}"
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit[each.key].id

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

output "routed_networks" {
  value = zipmap(
                values(libvirt_domain.domain-ubuntu)[*].name,
                values(libvirt_domain.domain-ubuntu)[*].network_interface[*]
                )
}
output "hosts" {
  # output does not support 'for_each', so use zipmap as workaround
  value = zipmap( 
                values(libvirt_domain.domain-ubuntu)[*].name,
                values(libvirt_domain.domain-ubuntu)[*].vcpu
                )
}
