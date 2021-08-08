variable "password" { default="linux" }
variable "dns_domain" { default="fabian.lee"  }
variable "ip_type" { default = "static" }

# kvm standard default network
variable "prefixIP" { default = "192.168.122" }

# kvm disk pool name
variable "diskPool" { default = "default" }

variable "virsh_network_name" { default = "default" }
