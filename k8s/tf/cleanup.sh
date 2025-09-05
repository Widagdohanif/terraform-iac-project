# Remove failed Helm releases
helm uninstall prometheus -n monitoring --ignore-not-found

# Clean up existing Kubernetes resources
kubectl delete deployment flask-app --ignore-not-found
kubectl delete deployment nginx-loadbalancer --ignore-not-found
kubectl delete service flask-app-service --ignore-not-found
kubectl delete service nginx-loadbalancer-service --ignore-not-found
kubectl delete configmap nginx-lb-config --ignore-not-found

# Clean up monitoring namespace
kubectl delete namespace monitoring --ignore-not-found

# Clean up Terraform state
cd k8s/tf
terraform state rm kubernetes_deployment.flask_app || true
terraform state rm kubernetes_deployment.nginx_lb || true
terraform state rm kubernetes_service.flask_app || true
terraform state rm kubernetes_service.nginx_lb || true
terraform state rm kubernetes_config_map.nginx_config || true
terraform state rm kubernetes_namespace.monitoring || true
terraform state rm helm_release.prometheus_stack || true
terraform state rm kubectl_manifest.flask_service_monitor || true
