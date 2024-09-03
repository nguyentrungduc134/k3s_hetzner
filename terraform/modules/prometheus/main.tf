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

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "61.9.0"
  values = [
    file("${path.module}/prometheus_values.yml")
  ]
}

#resource "kubectl_manifest" "cnpg_db_tools" {
#  yaml_body = file("${path.module}/servicemonitor.yml")
#  depends_on = [helm_release.prometheus]
#}


#resource "kubernetes_manifest" "app_monitor" {
#  depends_on = [resource.helm_release.prometheus]
#  manifest = yamldecode(file("${path.module}/servicemonitor.yml"))
#i}
resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig config -f modules/prometheus/servicemonitor.yml"
  }
  depends_on = [
    resource.helm_release.prometheus
  ]
}
