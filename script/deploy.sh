#!/bin/bash

set -e

PROJECT_ROOT=$(dirname "$(dirname "$(realpath "$0")")")
cd "$PROJECT_ROOT"

echo "🚀 Starting full deployment..."

# Build and push Flask app
echo "🔨 Build and Push Flask application..."
cd app/script
./build.sh

# Deploy infrastructure
echo "📡 Deploying EKS infrastructure..."
cd ../../iac
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Get cluster config
echo "🔧 Configuring kubectl..."
CLUSTER_NAME=$(terraform output -raw cluster_name)
AWS_REGION=$(terraform output -raw aws_region)
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

# Wait for cluster to be ready
echo "⏳ Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Deploy Kubernetes resources
echo "🎯 Deploying Kubernetes resources..."
cd ../k8s/tf
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Verify deployment
echo "✅ Verifying deployment..."
kubectl get all --all-namespaces

echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Access Information:"
echo "====================="
echo "Cluster Name: $CLUSTER_NAME"
echo "Flask App: kubectl port-forward svc/flask-app-service 8080:80"
echo "Nginx LB: kubectl port-forward svc/nginx-loadbalancer-service 8090:80" 
echo "Grafana: kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80"
echo "Grafana Password: $(cd ../tf && terraform output grafana_password)"
