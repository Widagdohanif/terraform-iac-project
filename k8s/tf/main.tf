# Flask Application
resource "kubernetes_deployment" "flask_app" {
  metadata {
    name      = "flask-app"
    namespace = "default"
    labels = {
      app = "flask-app"
    }
  }
  
  spec {
    replicas = var.flask_replicas
    
    selector {
      match_labels = {
        app = "flask-app"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "flask-app"
        }
      }
      
      spec {
        container {
          name  = "flask-app"
          image = var.flask_image
          
          port {
            container_port = 5000
          }
          
          # Minimal resource requests for t3.micro
          resources {
            requests = {
              memory = "64Mi"
              cpu    = "50m"
            }
            limits = {
              memory = "128Mi"
              cpu    = "100m"
            }
          }
          
          # More lenient probes
          liveness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 60
            period_seconds        = 30
            timeout_seconds       = 10
            failure_threshold     = 5
          }
          
          readiness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 30
            period_seconds        = 15
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }
      }
    }
  }
  
  # FIXED: Proper indexing for deployment
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      spec[0].template[0].metadata[0].labels,
      spec[0].template[0].metadata[0].annotations
    ]
  }
  
  # Add longer timeouts
  timeouts {
    create = "10m"
    update = "10m"
    delete = "5m"
  }
}

resource "kubernetes_service" "flask_app" {
  metadata {
    name      = "flask-app-service"
    namespace = "default"
    labels = {
      app = "flask-app"
    }
  }
  
  spec {
    selector = {
      app = "flask-app"
    }
    
    port {
      port        = 80
      target_port = 5000
      protocol    = "TCP"
      name        = "http"
    }
    
    type = "ClusterIP"
  }
  
  # FIXED: Proper indexing for service
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations
    ]
  }
}

# Nginx Load Balancer
resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name      = "nginx-lb-config"
    namespace = "default"
  }
  
  data = {
    "nginx.conf" = <<-EOT
      events {
          worker_connections 1024;
      }
      
      http {
          upstream flask_backend {
              server flask-app-service:80;
          }
          
          server {
              listen 80;
              
              location / {
                  proxy_pass http://flask_backend;
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
              }
              
              location /health {
                  access_log off;
                  return 200 "healthy\n";
                  add_header Content-Type text/plain;
              }
          }
      }
    EOT
  }
}

resource "kubernetes_deployment" "nginx_lb" {
  metadata {
    name      = "nginx-loadbalancer"
    namespace = "default"
    labels = {
      app = "nginx-lb"
    }
  }
  
  spec {
    replicas = var.nginx_replicas
    
    selector {
      match_labels = {
        app = "nginx-lb"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "nginx-lb"
        }
      }
      
      spec {
        container {
          name  = "nginx"
          image = "nginx:1.21-alpine"
          
          port {
            container_port = 80
          }
          
          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path   = "nginx.conf"
          }
          
          resources {
            requests = {
              memory = "64Mi"
              cpu    = "50m"
            }
            limits = {
              memory = "128Mi"
              cpu    = "100m"
            }
          }
          
          liveness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
          
          readiness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
        
        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.nginx_config.metadata[0].name
          }
        }
      }
    }
  }
  
  # FIXED: Proper indexing for nginx deployment
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
      spec[0].template[0].metadata[0].labels,
      spec[0].template[0].metadata[0].annotations
    ]
  }
  
  timeouts {
    create = "10m"
    update = "10m"
    delete = "5m"
  }
}

resource "kubernetes_service" "nginx_lb" {
  metadata {
    name      = "nginx-loadbalancer-service"
    namespace = "default"
    labels = {
      app = "nginx-lb"
    }
  }
  
  spec {
    selector = {
      app = "nginx-lb"
    }
    
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
      name        = "http"
    }
    
    type = "LoadBalancer"
  }
  
  # ADDED: Lifecycle for nginx service
  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations
    ]
  }
}

# Monitoring Stack
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus_stack" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata.name
  version    = "51.2.0"
  
  # INCREASE TIMEOUT for slow t3.micro cluster
  timeout = 900  # 15 minutes instead of default 5
  
  # LIGHTWEIGHT CONFIG for resource-constrained cluster
  set {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }
  
  # Disable resource-heavy components
  set {
    name  = "alertmanager.enabled"
    value = "false"
  }
  
  set {
    name  = "nodeExporter.enabled"
    value = "false"
  }
  
  set {
    name  = "kubeStateMetrics.enabled" 
    value = "true"
  }
  
  # Reduce resource requests for t3.micro
  set {
    name  = "prometheus.prometheusSpec.resources.requests.memory"
    value = "256Mi"
  }
  
  set {
    name  = "prometheus.prometheusSpec.resources.limits.memory"
    value = "512Mi"
  }
  
  set {
    name  = "grafana.resources.requests.memory"
    value = "128Mi"
  }
  
  set {
    name  = "grafana.resources.limits.memory" 
    value = "256Mi"
  }
  
  depends_on = [kubernetes_namespace.monitoring]
}


# ServiceMonitor for Flask app
resource "kubectl_manifest" "flask_service_monitor" {
  yaml_body = yamlencode({
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "flask-service-monitor"
      namespace = "default"
      labels = {
        release = "prometheus"
        app     = "flask-app"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app = "flask-app"
        }
      }
      endpoints = [{
        port     = "http"
        path     = "/metrics"
        interval = "30s"
      }]
      namespaceSelector = {
        matchNames = ["default"]
      }
    }
  })
  
  depends_on = [
    helm_release.prometheus_stack,
    kubernetes_service.flask_app
  ]
}
