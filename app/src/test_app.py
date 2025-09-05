import pytest
import json
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_endpoint(client):
    """Test the home endpoint"""
    response = client.get('/')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['message'] == 'Flask app is running!'
    assert 'version' in data

def test_health_endpoint(client):
    """Test the health check endpoint"""
    response = client.get('/health')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['status'] == 'healthy'
    assert data['service'] == 'flask-app'

def test_metrics_endpoint(client):
    """Test the Prometheus metrics endpoint"""
    response = client.get('/metrics')
    assert response.status_code == 200
    assert b'flask_requests_total' in response.data
    assert b'flask_request_duration_seconds' in response.data

def test_api_status_endpoint(client):
    """Test the API status endpoint"""
    response = client.get('/api/status')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['api'] == 'operational'

def test_api_error_endpoint(client):
    """Test the error endpoint"""
    response = client.get('/api/error')
    assert response.status_code == 500
    data = json.loads(response.data)
    assert 'error' in data

def test_metrics_collection(client):
    """Test that metrics are being collected"""
    # Make a few requests to generate metrics
    client.get('/')
    client.get('/health')
    client.get('/api/status')
    
    response = client.get('/metrics')
    metrics_data = response.data.decode('utf-8')
    
    # Check that request counts are being tracked
    assert 'flask_requests_total' in metrics_data
    assert 'method="GET"' in metrics_data
    assert 'endpoint="home"' in metrics_data
