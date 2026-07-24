# --- KMS Key for EKS Secrets Encryption ---

resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for EKS secrets encryption and CloudWatch Logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/eks/${var.project_name}-${var.environment}/cluster"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-secrets"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "eks_secrets" {
  name          = "alias/${var.project_name}-${var.environment}-eks-secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}

# --- CloudWatch Log Group for EKS Control Plane ---

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.project_name}-${var.environment}/cluster"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.eks_secrets.arn

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}