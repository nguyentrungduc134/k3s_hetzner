terraform {
  required_version = ">= 1.5.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.43.0"
    }

  }
}

resource "helm_release" "redis-operator" {
  name       = "redis-operator"
  chart      = "redis-operator"
  repository = "https://ot-container-kit.github.io/helm-charts/"
  timeout    = 600
  namespace  = "redis"
  create_namespace = "true"
}

resource "helm_release" "redis-cluster" {
  name       = "redis-cluster"
  chart      = "${path.module}/redis-cluster"
  timeout    = 600
  namespace  = "redis"
  values = [
    templatefile("${path.module}/values.yaml", {
      volume_size                = var.redis_config.volume_size
    })
]
}

