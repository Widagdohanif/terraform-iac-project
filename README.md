# Terraform Cloud IAC Project 

A **cloud-native application** deployed on **AWS Elastic Kubernetes Service (EKS)**, orchestrated with **Terraform**, containerized with **Docker**, powered by **Flask**, and monitored by **Prometheus** and **Grafana**.

---

## Project Structure
```
├── app
│   ├── script
│   │   └── build.sh  # Build application
│   └── src
│       ├── app.py  # Flask application source
│       ├── Dockerfile            
│       ├── requirements.txt
│       └── test_app.py     # Unit tests
├── iac                            # Infrastructure as Code (Terraform)
│   ├── eks.tf                    
│   ├── iam.tf 
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars
│   ├── tfplan
│   ├── variable.tf
│   └── vpc.tf
├── k8s    # Kubernetes manifests
│   ├── manifest
│   │   ├── app   # Application manifests
│   │   │   ├── app-deploy.yaml
│   │   │   └── app-service.yaml
│   │   ├── monitoring
│   │   │   ├── prometheus.yaml
│   │   │   └── value.yml
│   │   └── nginx    # Ingress/Nginx configuration
│   │       ├── configmap.yaml
│   │       ├── deployment.yaml
│   │       └── services.yaml
│   └── tf     # Terraform for Kubernetes resources
│       ├── cleanup.sh
│       ├── main.tf
│       ├── providers.tf
│       ├── tfplan
│       └── variables.tf
└── script    # Deployment and test scripts
   ├── deploy.sh
   ├── destroy.sh
   └── test.sh


```
---

## Technologies

- **Terraform**: Infrastructure provisioning and management
- **AWS**: Cloud provider (EKS, VPC, IAM, etc.)
- **Kubernetes (EKS)**: Container orchestration
- **Docker**: Application containerization
- **Flask**: Python web framework (backend)
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Metrics visualization and dashboards

---

## Design Overview

This project demonstrates a **microservices architecture** deployed on AWS using **Infrastructure as Code (IaC)**. The Flask application runs inside Docker containers managed by Kubernetes. Terraform provisions the AWS resources, including the EKS cluster, networking, and IAM roles. Kubernetes manifests define the application deployment, services, and monitoring stack. The monitoring stack (Prometheus and Grafana) provides observability into application and cluster health.

---

## Getting Started

### Prerequisites

- **AWS account** with appropriate permissions
- **Terraform** installed
- **kubectl** and **awscli** configured
- **Docker** installed

### Installation

1. **Clone the repository**
2. **Initialize Terraform**  
   `cd iac && terraform init`
3. **Review and customize variables** in `terraform.tfvars` as needed.
4. **Apply Terraform** to provision AWS resources  
   `terraform apply`
5. **Configure kubectl** to access your EKS cluster  
   `aws eks --region <region> update-kubeconfig --name <cluster-name>`
6. **Build and push the Docker image**  
   `cd app && ./script/build.sh`
7. **Deploy the application and monitoring stack**  
   `kubectl apply -f k8s/manifest/app/`  
   `kubectl apply -f k8s/manifest/monitoring/`  
   `kubectl apply -f k8s/manifest/nginx/`

### Deployment Scripts

- **deploy.sh**: Automated deployment script (optional)
- **destroy.sh**: Cleanup script for tearing down resources
- **test.sh**: Run application tests

---

## Monitoring and Observability

- **Prometheus** is deployed to collect metrics from the application and Kubernetes cluster.
- **Grafana** provides dashboards for visualizing metrics.
- Access Grafana dashboards via the service endpoint (use `kubectl get svc` to find the URL).

---

## Acknowledgments

- **AWS** for managed Kubernetes (EKS)
- **Hashicorp** for Terraform
- **Prometheus** and **Grafana** for observability
