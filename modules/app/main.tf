resource "kubernetes_ingress_v1" "example_ingress" {
  metadata {
    name = "example-ingress"
  }

  spec {
    ingress_class_name = "haproxy"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "app"

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "app"

    labels = {
      tier = "frontend"
    }
  }

  spec {
    selector {
      match_labels = {
        app  = "app"
        tier = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app  = "app"
          tier = "frontend"
        }
      }

      spec {
        container {
          name              = "app"
          image             = "ducnt134/go_app"
          image_pull_policy = "Always"
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = "app"

    labels = {
      tier = "frontend"
    }
  }

  spec {
    port {
      name        = "app"
      protocol    = "TCP"
      port        = 80
      target_port = "8080"
    }

    selector = {
      app  = "app"
      tier = "frontend"
    }
  }
}

