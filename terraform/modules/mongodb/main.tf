resource "helm_release" "mongodb" {
  name       = "mongodb"
  chart      = "mongodb"
  #version   = "15.6.22"
  #upgrade_install = "true"
  timeout    = 600
  repository = "https://charts.bitnami.com/bitnami"
  values = [
    templatefile("${path.module}/values.yaml", {
      volume_size                = var.mongodb_config.volume_size
    })
]
}
