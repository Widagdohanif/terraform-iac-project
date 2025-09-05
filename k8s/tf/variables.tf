variable "flask_image" {
  description = "Flask application Docker image"
  type        = string
  default     = "rr7x/iac-project:latest"
}

variable "flask_replicas" {
  description = "Number of Flask app replicas"
  type        = number
  default     = 2
}

variable "nginx_replicas" {
  description = "Number of Nginx replicas"
  type        = number
  default     = 2
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}
