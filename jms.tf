terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
}

provider "kubernetes" {
  # Configuration options
    config_path = "~/.kube/config"
}

resource "kubernetes_namespace_v1" "devops_ns" {
  metadata {
  name = "devops-ns"
  }
}

resource "kubernetes_deployment_v1" "nginx_server" {
  metadata {
      name      = "nginx-server"
      namespace = kubernetes_namespace_v1.devops_ns.metadata.0.name
  }
 spec {
   replicas = 5
   selector {
        match_labels = {
            app = "devops-job"
        }
   }

    template {
        metadata {
          labels = {
            app = "devops-job"
          }
        }

    spec {
      container {
        name = "nginx"
        image = "nginx:latest"
        image_pull_policy = "IfNotPresent"

        port {
          container_port = 8080
        } 
    }
   }
  }
 }
}

resource "kubernetes_service_v1" "nginx_svc" {
    metadata {
      
      name      = "${kubernetes_deployment_v1.nginx_server.metadata.0.name}-svc"
      namespace = kubernetes_namespace_v1.devops_ns.metadata.0.name
    }
spec {
  #type = "LoadBalancer"

  selector = {
    app = kubernetes_deployment_v1.nginx_server.spec.0.selector.0.match_labels.app
  }
port {
  target_port = kubernetes_deployment_v1.nginx_server.spec.0.template.0.spec.0.container.0.port.0.container_port
  port        = 1009
  
}

}
  
}