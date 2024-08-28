locals {
  # You have the choice of setting your Hetzner API token here or define the TF_VAR_hcloud_token env
  # within your shell, such as: export TF_VAR_hcloud_token=xxxxxxxxxxx
  # If you choose to define it in the shell, this can be left as is.

  # Your Hetzner token can be found in your Project > Security > API Token (Read & Write is required).
  hcloud_token = var.hcloud_token
}

module "kube-hetzner" {
  providers = {
    hcloud = hcloud
  }
  hcloud_token = var.hcloud_token != "" ? var.hcloud_token : local.hcloud_token

  # For normal use, this is the path to the terraform registry
  source = "kube-hetzner/kube-hetzner/hcloud"

  # * Your ssh public key
  ssh_public_key = file("id_rsa.pub")
  # * Your private key must be "ssh_private_key = null" when you want to use ssh-agent for a Yubikey-like device authentication or an SSH key-pair with a passphrase.
  ssh_private_key = file("id_rsa")
  # * For Hetzner locations see https://docs.hetzner.com/general/others/data-centers-and-connection/
  network_region = "us-west" # change to `us-east` if location is ash
  ingress_controller = "nginx"
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
      name        = "agent-small",
      server_type = "cpx11",
      location    = "hil",
      labels      = [],
      taints      = [],
      count       = var.nodes
      # swap_size   = "2G" # remember to add the suffix, examples: 512M, 1G
      # zram_size   = "2G" # remember to add the suffix, examples: 512M, 1G
      # kubelet_args = ["kube-reserved=cpu=50m,memory=300Mi,ephemeral-storage=1Gi", "system-reserved=cpu=250m,memory=300Mi"]

      # Fine-grained control over placement groups (nodes in the same group are spread over different physical servers, 10 nodes per placement group max):
      # placement_group = "default"

      # Enable automatic backups via Hetzner (default: false)
      # backups = true
    }
  ]

  # * LB location and type, the latter will depend on how much load you want it to handle, see https://www.hetzner.com/cloud/load-balancer
  load_balancer_type     = "lb11"
  load_balancer_location = "hil"

   autoscaler_nodepools = [
     {
       name        = "autoscaled-small"
       server_type = "cpx11"
       location    = "hil"
       min_nodes   = var.min_nodes
       max_nodes   = var.max_nodes
       # kubelet_args = ["kube-reserved=cpu=250m,memory=1500Mi,ephemeral-storage=1Gi", "system-reserved=cpu=250m,memory=300Mi"]
     }
   ]
  # cluster_autoscaler_image = "registry.k8s.io/autoscaling/cluster-autoscaler"
  # cluster_autoscaler_version = "v1.30.1"
  # cluster_autoscaler_log_level = 4
  # cluster_autoscaler_log_to_stderr = true
  # cluster_autoscaler_stderr_threshold = "INFO"
  # cluster_autoscaler_server_creation_timeout = 15
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
  dns_servers = [
    "1.1.1.1",
    "8.8.8.8",
    "2606:4700:4700::1111",
  ]

   extra_firewall_rules = [
     {
       description = "For Postgres"
       direction       = "in"
       protocol        = "tcp"
       port            = "30007"
       source_ips      = ["0.0.0.0/0", "::/0"]
       destination_ips = [] # Won't be used for this rule
     }
   ]

  # csi-driver-smb, all csi-driver-smb helm values can be found at https://github.com/kubernetes-csi/csi-driver-smb/blob/master/charts/latest/csi-driver-smb/values.yaml
  # The following is an example, please note that the current indentation inside the EOT is important.
     csi_driver_smb_values = <<EOT
controller:
  name: csi-smb-controller
  replicas: 1
  runOnMaster: false
  runOnControlPlane: false
  resources:
    csiProvisioner:
      limits:
        memory: 300Mi
      requests:
        cpu: 10m
        memory: 20Mi
    livenessProbe:
      limits:
        memory: 100Mi
      requests:
        cpu: 10m
        memory: 20Mi
    smb:
      limits:
        memory: 200Mi
      requests:
        cpu: 10m
        memory: 20Mi
  EOT 



  # If you want to use a specific Nginx helm chart version, set it below; otherwise, leave them as-is for the latest versions.
  # nginx_version = ""

  # Nginx, all Nginx helm values can be found at https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml
  # You can also have a look at https://kubernetes.github.io/ingress-nginx/, to understand how it works, and all the options at your disposal.
  # The following is an example, please note that the current indentation inside the EOT is important.
     nginx_values = <<EOT
controller:
  watchIngressWithoutClass: "true"
  kind: "DaemonSet"
  config:
    "use-forwarded-headers": "true"
    "compute-full-forwarded-for": "true"
    "use-proxy-protocol": "true"
  service:
    annotations:
      "load-balancer.hetzner.cloud/name": "k3s"
      "load-balancer.hetzner.cloud/use-private-ip": "false"
      "load-balancer.hetzner.cloud/disable-private-ingress": "true"
      "load-balancer.hetzner.cloud/location": "hil"
      "load-balancer.hetzner.cloud/type": "lb11"
      "load-balancer.hetzner.cloud/uses-proxyprotocol": "true"
  EOT 
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
  }
}

output "kubeconfig" {
  value     = module.kube-hetzner.kubeconfig
  sensitive = true
}

variable "hcloud_token" {
  sensitive = true
  default   = ""
}
