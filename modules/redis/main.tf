resource "helm_release" "rediscluster" {
  name       = "redis-cluster"
  chart      = "redis-cluster"
  timeout    = 600
  version    = "11.0.3"
  repository = "https://charts.bitnami.com/bitnami"
  values = [
    templatefile("${path.module}/values.yaml", {
      volume_size                = var.redis_config.volume_size
    })
  ]
}
