provider "kubernetes" {
    host = "${var.host_address}"
    token = "${var.token}"
    insecure = true
}

resource "kubernetes_pod" "echo" {
  metadata {
    name = "echo-example"
    labels {
      App = "echo"
    }
  }
  spec {
    container {
      image = "hashicorp/http-echo:0.2.1"
      name  = "example2"
      args = ["-listen=:80", "-text='Hello World'"]
      port {
        container_port = 80
      }
    }
  }
}

resource "kubernetes_service" "echo" {
  metadata {
    name = "echo-example"
  }
  spec {
    selector {
      App = "${kubernetes_pod.echo.metadata.0.labels.App}"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
 }
}

resource "kubernetes_resource_quota" "example" {
  metadata {
    name = "echo-example"
  }
  spec {
    hard {
      pods = 10
    }
    scopes = ["BestEffort"]
  }
}
