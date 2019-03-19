provider "kubernetes" {
    host = "${var.host_address}"
    token = "${var.token}"
    insecure = true
}

resource "kubernetes_pod" "echo" {
  metadata {
    name = "hackathon-awesomeness"
    labels {
      App = "echo"
    }
  }
  spec {
    container {
      image = "hashicorp/http-echo:0.2.1"
      name  = "hackathon-awesomeness-for-real"
      args = ["-listen=:80", "-text='Hello World'"]
      port {
        container_port = 80
      }
    }
  }
}

resource "kubernetes_service" "echo" {
  metadata {
    name = "hackathon-awesomeness"
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
    name = "hackathon-awesomeness"
  }
  spec {
    hard {
      pods = 5
    }
    scopes = ["BestEffort"]
  }
}
