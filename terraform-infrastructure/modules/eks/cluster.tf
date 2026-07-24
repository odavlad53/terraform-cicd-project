# --- EKS Cluster ---

resource "aws_eks_cluster" "this" {
  #checkov:skip=CKV_AWS_39: Lab scope - kubectl access requires public endpoint
  #checkov:skip=CKV_AWS_38: Lab scope - public endpoint temporarily open for VPN IP rotation issues
  name     = "${var.project_name}-${var.environment}"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.31"

  # Enable all control plane log types for auditing
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # Encrypt Kubernetes secrets at rest with a customer-managed KMS key
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
    resources = ["secrets"]
  }

  vpc_config {
    subnet_ids = concat(
      var.private_subnet_ids,
      var.public_subnet_ids
    )
    endpoint_private_access = true
    endpoint_public_access  = true
    # Dynamically resolved — see data "http" "my_ip" and locals block above
    public_access_cidrs = local.eks_access_cidrs
  }

  lifecycle {
    ignore_changes = [vpc_config[0].public_access_cidrs]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_cloudwatch_log_group.eks,
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# --- Managed Node Group ---

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-${var.environment}-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.eks_ecr_read,
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-nodes"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}