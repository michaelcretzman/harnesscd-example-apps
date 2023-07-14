provider "kubernetes" {
  config_context_cluster = "docs-tf"  # Name of your Kubernetes cluster
  host                   = "<KUBE_HOST>"     # Kubernetes API server host
  client_certificate     = "<CLIENT_CERT>"   # Path to client certificate
  client_key             = "<CLIENT_KEY>"    # Path to client key
  cluster_ca_certificate = "<CLUSTER_CA>"    # Path to cluster CA certificate
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = "example-namespace"
  }
}

resource "kubernetes_service_account" "example" {
  metadata {
    name      = "example-service-account"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "example" {
  metadata {
    name      = "example-cluster-role-binding"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.example.metadata[0].name
    namespace = kubernetes_namespace.example.metadata[0].name
  }
}

resource "kubernetes_deployment" "example" {
  metadata {
    name      = "example-deployment"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "example-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "example-app"
        }
      }

      spec {
        container {
          image = "nginx:latest"
          name  = "example-container"
        }
      }
    }
  }
}

output "default_namespace" {
  value = kubernetes_namespace.example.metadata[0].name
}
