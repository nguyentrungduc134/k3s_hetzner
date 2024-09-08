terraform {
  required_version = ">= 1.5.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }

  }
}

resource "hcloud_server" "mongodb_server" {
  count = 3
  name        = "app${count.index + 1}"
  server_type = "cpx31"
  image       = "ubuntu-22.04"
  location    = "hil"
  network {
        network_id = var.network_id
        ip         = "10.128.0.${count.index + 1}"
        alias_ips = []   
}
  depends_on = [
    var.subnet_id
  ]
}
