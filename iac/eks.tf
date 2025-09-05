resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version
  
  vpc_config {
    subnet_ids             = module.vpc.public_subnets
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs    = ["0.0.0.0/0"]
  }
  
  enabled_cluster_log_types = []
  
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
  ]
  
  tags = var.common_tags
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  
  subnet_ids = module.vpc.public_subnets
  
  capacity_type  = "SPOT"
  instance_types = ["t3.micro"]
  
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  
  update_config {
    max_unavailable = 1
  }
  
  disk_size = 20
  
  # SSH ACCESS CONFIGURATION
  remote_access {
    ec2_ssh_key               = "golkey"  # Your existing keypair name
    source_security_group_ids = [aws_security_group.node_ssh.id]
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
  
  tags = var.common_tags
}

resource "aws_security_group" "node_ssh" {
  name_prefix = "${var.cluster_name}-node-ssh-"
  vpc_id      = module.vpc.vpc_id
  
  description = "Security group for SSH access to EKS nodes"
  
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP for security
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-node-ssh-sg"
  })
}
