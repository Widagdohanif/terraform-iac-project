from flask import Flask, Response, jsonify, request
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter(
    'flask_requests_total', 
    'Total Flask requests', 
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'flask_request_duration_seconds', 
    'Flask request duration in seconds'
)

ACTIVE_REQUESTS = Counter(
    'flask_active_requests', 
    'Currently active Flask requests'
)

@app.before_request
def before_request():
    """Record request start time"""
    request.start_time = time.time()

@app.after_request  
def after_request(response):
    """Record metrics after request"""
    # Calculate duration
    request_duration = time.time() - request.start_time
    REQUEST_DURATION.observe(request_duration)
    
    # Count requests by method, endpoint, and status
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown',
        status=response.status_code
    ).inc()
    
    return response

@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint - WAJIB ADA"""
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'flask-app',
        'timestamp': time.time()
    }), 200

@app.route('/')
def home():
    """Home endpoint"""
    return jsonify({
        'message': 'Flask app is running!',
        'version': '1.0.0',
        'endpoints': {
            'health': '/health',
            'metrics': '/metrics'
        }
    }), 200

# Tambahan endpoint untuk testing
@app.route('/api/status')
def api_status():
    """API status endpoint"""
    return jsonify({
        'api': 'operational',
        'timestamp': time.time()
    }), 200

@app.route('/api/error')
def api_error():
    """Test error endpoint for monitoring"""
    return jsonify({'error': 'Test error for monitoring'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
