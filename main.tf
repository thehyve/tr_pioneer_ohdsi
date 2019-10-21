# main.tf

# Define terraform backend
terraform {
  required_version = "~> 0.12.0"
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "TheHyve"
    workspaces {
      name = "pioneer"
    }
  }
}

# Definition of variables
variable "hcloud_token" {
  type = string
  description = "Use -var='hcloud_token=...' CLI option"
}
variable "server_type" {
  type = string
  description = "defines resources for provisioned server"
  default = "cx51-ceph"
}
variable "ssh_key" {
  type = string
  description = "An id of public key of ssh key-pairs that will be used for connection to a server. Export TF_VAR_ssh_key environment variable to define a value."
}
variable "server_image" {
  type = string
  description = "An image being used for a server provisioning."
  default = "ubuntu-16.04"
}

# User Hetzner cloud
provider "hcloud" {
  token = "${var.hcloud_token}"
}

resource "hcloud_server" "ohdsi" {
  name = "pioneer.thehyve.net"
  server_type = "${var.server_type}"
  image = "${var.server_image}"
  user_data = "${file("cloud_init")}"
  ssh_keys = [
    "${var.ssh_key}",
  ]
}
resource "hcloud_volume" "ohdsi_vol" {
  name = "volume1"
  size = 260
  server_id = "${hcloud_server.ohdsi.id}"
  automount = false
  format = "xfs"
}
