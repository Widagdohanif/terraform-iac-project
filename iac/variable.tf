variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"  # Cheapest region
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "learning-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "learning"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

# COST SAVING: Smallest possible instances
variable "node_group_instance_types" {
  description = "EC2 instance types"
  type        = list(string)
  default     = ["t3.micro", "t3.small"]  # Cheapest options
}

# COST SAVING: SPOT instances (up to 90% cheaper)
variable "node_group_capacity_type" {
  description = "Use SPOT instances to save cost"
  type        = string
  default     = "SPOT"
}

# COST SAVING: Minimal scaling
variable "node_group_scaling" {
  description = "Minimal node group scaling"
  type = object({
    min_size     = number
    max_size     = number
    desired_size = number
  })
  default = {
    min_size     = 1  # Minimum possible
    max_size     = 2  # Keep small
    desired_size = 1  # Start with just 1 node
  }
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Project     = "learning"
    Environment = "development"
    Purpose     = "cost-optimization"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
