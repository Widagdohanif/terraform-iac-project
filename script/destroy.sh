#!/bin/bash

set -e

PROJECT_ROOT=$(dirname "$(dirname "$(realpath "$0")")")
cd "$PROJECT_ROOT"

echo "🗑️  Starting cleanup process..."

# Cleanup Kubernetes resources first
echo "🧹 Cleaning up Kubernetes resources..."
cd k8s/tf
if [ -f "terraform.tfstate" ]; then
    terraform destroy -auto-approve
fi

# Cleanup infrastructure
echo "🏗️  Cleaning up infrastructure..."
cd ../../iac
if [ -f "terraform.tfstate" ]; then
    terraform destroy -auto-approve
fi

echo "✅ Cleanup completed!"
