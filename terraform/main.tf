locals {
  hcloud_token = var.hcloud_token
}


resource "local_file" "kubeconfig" {
  depends_on = [module.kube-hetzner]
  filename   = "config"
  content    = module.kube-hetzner.kubeconfig
}

resource "hcloud_network" "priv" {
  name     = "k3s"
  ip_range = "10.0.0.0/8"
}
module "kube-hetzner" {
  providers = {
    hcloud = hcloud
  }
  hcloud_token = var.hcloud_token != "" ? var.hcloud_token : local.hcloud_token
  #hcloud_ssh_key_id = "22751685"
  # For normal use, this is the path to the terraform registry
  source = "kube-hetzner/kube-hetzner/hcloud"
  version = "2.14.4"
  initial_k3s_channel = "v1.30"
  network_region = "us-west" # change to `us-east` if location is ash
  existing_network_id = [hcloud_network.priv.id]
  network_ipv4_cidr="10.0.0.0/9"
  # * Your ssh public key
  ssh_public_key = file("credentials/id_rsa.pub")
  # * Your private key must be "ssh_private_key = null" when you want to use ssh-agent for a Yubikey-like device authentication or an SSH key-pair with a passphrase.
  ssh_private_key = file("credentials/id_rsa")
  # * For Hetzner locations see https://docs.hetzner.com/general/others/data-centers-and-connection/
  ingress_controller = "haproxy"
 # use_control_plane_lb = true
  control_plane_nodepools = [
    {
      name        = "control-plane-hil",
      server_type = "cpx31",
      location    = "hil",
      labels      = [],
      taints      = [],
      count       = var.master_nodes 
      # swap_size   = "2G" # remember to add the suffix, examples: 512M, 1G
      # zram_size   = "2G" # remember to add the suffix, examples: 512M, 1G
      # kubelet_args = ["kube-reserved=cpu=250m,memory=1500Mi,ephemeral-storage=1Gi", "system-reserved=cpu=250m,memory=300Mi"]

      # Fine-grained control over placement groups (nodes in the same group are spread over different physical servers, 10 nodes per placement group max):
      # placement_group = "default"

      # Enable automatic backups via Hetzner (default: false)
      # backups = true
    }
  ]

  agent_nodepools = [
    {
      name        = "agent-redis",
      server_type = "cpx31",
      location    = "hil",
      labels      = [
        "dedicated=redis"
      ],
       taints      = [],
       count       = 3
      # Enable automatic backups via Hetzner (default: false)
      # backups = true
    },

    {
      name        = "agent-app",
      server_type = "cpx31",
      location    = "hil",
      labels      = [
        "dedicated=app"
      ],
       taints      = [
        "dedicated=app:NoSchedule"
      ],
       count       = 3
      # Enable automatic backups via Hetzner (default: false)
      # backups = true
    },


  ]

  # * LB location and type, the latter will depend on how much load you want it to handle, see https://www.hetzner.com/cloud/load-balancer
  load_balancer_type     = "lb11"
  load_balancer_location = "hil"

   autoscaler_nodepools = [
     {
       name        = "autoscaled-redis"
       server_type = "cpx31"
       location    = "hil"
       min_nodes   = var.min_nodes
       max_nodes   = var.max_nodes
     },
     {
       name        = "autoscaled-app"
       server_type = "cpx31"
       location    = "hil"
       min_nodes   = var.min_nodes
       max_nodes   = var.max_nodes
     }

   ]

   cluster_autoscaler_version = "v1.30.1"
   cluster_autoscaler_server_creation_timeout = 30
k3s_registries = <<-EOT
    mirrors:
      hub.docker.com:
        endpoint:
          - "hub.docker.com"
    configs:
      hub.docker.com:
        auth:
          username: ${var.docker_username}
          password: ${var.docker_password}
  EOT
#  dns_servers = [
 #   "1.1.1.1",
  #  "8.8.8.8",
   # "2606:4700:4700::1111",
 # ]
 create_kubeconfig = true

   extra_firewall_rules = [
     {
       description = "Open for Grafana"
       direction       = "in"
       protocol        = "tcp"
       port            = "30009"
       source_ips      = ["0.0.0.0/0"]
       destination_ips = [] # Won't be used for this rule
     },
     {
       description = "Open for MongoDB"
       direction       = "in"
       protocol        = "tcp"
       port            = "30001"
       source_ips      = ["10.0.0.0/8"]
       destination_ips = [] # Won't be used for this rule
     },
     {
       description = "Open for MongoDB"
       direction       = "in"
       protocol        = "tcp"
       port            = "30002"
       source_ips      = ["10.0.0.0/8"]
       destination_ips = [] # Won't be used for this rule
     },
     {
       description = "Open for MongoDB"
       direction       = "in"
       protocol        = "tcp"
       port            = "30003"
       source_ips      = ["10.0.0.0/8"]
       destination_ips = [] # Won't be used for this rule
     }


   ]


  # Cloudflare trusted IPs:
   haproxy_additional_proxy_protocol_ips = [
     "173.245.48.0/20",
     "103.21.244.0/22",
     "103.22.200.0/22",
     "103.31.4.0/22",
     "141.101.64.0/18",
     "108.162.192.0/18",
     "190.93.240.0/20",
     "188.114.96.0/20",
     "197.234.240.0/22",
     "198.41.128.0/17",
     "162.158.0.0/15",
     "104.16.0.0/13",
     "104.24.0.0/14",
     "172.64.0.0/13",
     "131.0.72.0/22",
     "2400:cb00::/32",
     "2606:4700::/32",
     "2803:f800::/32",
     "2405:b500::/32",
     "2405:8100::/32",
     "2a06:98c0::/29",
     "2c0f:f248::/32"
   ]
}
module "prometheus" {
  source = "./modules/prometheus/"
  depends_on = [module.kube-hetzner]

}



provider "hcloud" {
  token = var.hcloud_token != "" ? var.hcloud_token : local.hcloud_token
}

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

  }
}


resource "hcloud_network_subnet" "mongodb-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.priv.id
  network_zone = "us-west"
  ip_range     = "10.128.0.0/24"
}

module "mongodb" {
  source = "./modules/mongodb/"
  network_id = hcloud_network.priv.id
  subnet_id = hcloud_network_subnet.mongodb-subnet.id
  depends_on = [resource.hcloud_network_subnet.mongodb-subnet]
}


output "kubeconfig" {
  value     = module.kube-hetzner.kubeconfig
  sensitive = true
}

variable "hcloud_token" {
  sensitive = true
  default   = ""
}
provider "kubernetes" {
  config_path    = "${local_file.kubeconfig.filename}"
}

provider "helm" {
  kubernetes {
    config_path = "${local_file.kubeconfig.filename}"
  }
}




