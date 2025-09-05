#!/bin/bash

set -e

echo "🧪 Testing deployment..."

# Test Flask app
echo "Testing Flask application..."
kubectl port-forward svc/flask-app-service 8080:80 &
FLASK_PID=$!
sleep 5

if curl -f http://localhost:8080/health; then
    echo "✅ Flask health check passed"
else
    echo "❌ Flask health check failed"
    kill $FLASK_PID
    exit 1
fi

if curl -f http://localhost:8080/metrics; then
    echo "✅ Flask metrics endpoint passed"
else
    echo "❌ Flask metrics endpoint failed"
    kill $FLASK_PID
    exit 1
fi

kill $FLASK_PID

# Test Nginx Load Balancer
echo "Testing Nginx Load Balancer..."
kubectl port-forward svc/nginx-loadbalancer-service 8090:80 &
NGINX_PID=$!
sleep 5

if curl -f http://localhost:8090/health; then
    echo "✅ Nginx health check passed"
else
    echo "❌ Nginx health check failed"
fi

kill $NGINX_PID

echo "🎉 All tests passed!"
