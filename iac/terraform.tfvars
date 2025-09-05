# terraform.tfvars
aws_region    = "us-east-1"        # Cheapest region
cluster_name  = "learning-cluster"
environment   = "learning"

# Ultra-minimal setup
node_group_scaling = {
  min_size     = 1
  max_size     = 2  
  desired_size = 1
}

node_group_instance_types = ["t3.micro"]  # Cheapest
node_group_capacity_type  = "SPOT"        # 90% discount

common_tags = {
  Project     = "learning"
  Environment = "development"
  CostCenter  = "learning"
  AutoShutdown = "enabled"
}
