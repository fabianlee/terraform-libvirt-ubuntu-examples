# https://fabianlee.org/2021/07/05/kvm-installing-terraform-and-the-libvirt-provider-for-local-kvm-resources/
terraform {
  required_version = ">= 0.14"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.10"
    }
  }
}

# instance of the provider
provider "libvirt" {
  uri = "qemu:///system"
}

