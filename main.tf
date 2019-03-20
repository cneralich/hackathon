terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "lanceplarsenv2"

    workspaces {
      prefix = "k8s-"
    }
  }
}

# --------------------------------------------------------------------------------
# Kubernetes
# --------------------------------------------------------------------------------

provider "kubernetes" {
    host = "${var.host_address}"
    token = "${var.token}"
    insecure = true
}

resource "kubernetes_pod" "echo" {
  metadata {
    name = "${var.name}"
    labels {
      App = "echo"
    }
  }
  spec {
    container {
      image = "hashicorp/http-echo:0.2.1"
      name  = "${var.name}"
      args = ["-listen=:80", "-text='Brian Lee, 20 over par through 4'"]
      port {
        container_port = 80
      }
    }
  }
}

resource "kubernetes_service" "echo" {
  metadata {
    name = "${var.name}"
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
    name = "${var.name}"
  }
  spec {
    hard {
      pods = 5
    }
    scopes = ["BestEffort"]
  }
}

# --------------------------------------------------------------------------------
# VAULT
# --------------------------------------------------------------------------------
/*provider "vault" {
  address = "${var.vault_addr}"
}

data "vault_generic_secret" "k8s_credentials" {
  path = "secret/${var.vault_user}/kubernetes/credentials"
}*/
