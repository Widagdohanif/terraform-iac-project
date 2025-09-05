#!/bin/bash

set -e

echo "🔨 Building Flask application..."

cd "$(dirname "$0")/../src"

# Build Docker image
docker build -t rr7x/iac-project:latest .

# Tag for different environments
docker tag rr7x/iac-project:latest rr7x/iac-project:dev

echo "✅ Flask application built successfully!"
echo "Image: rr7x/iac-project:latest"

echo "📤 Pushing Flask application to registry..."

# Push to Docker Hub
docker push rr7x/iac-project:latest
docker push rr7x/iac-project:dev

echo "✅ Flask application pushed successfully!"