module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  
  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"
  
  # FIX: Use at least 2 different AZs
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
  
  # FIX: Create subnets in different AZs
  private_subnets = [
    "10.0.1.0/24",  # AZ-a
    "10.0.2.0/24"   # AZ-b
  ]
  
  public_subnets = [
    "10.0.101.0/24", # AZ-a  
    "10.0.102.0/24"  # AZ-b
  ]
  
  # COST SAVING: Keep NAT gateway disabled for learning
  enable_nat_gateway   = false
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  # Allow public IP (since no NAT Gateway)
  map_public_ip_on_launch = true
  
  # EKS tags
  tags = merge(var.common_tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
  
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
  
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}
