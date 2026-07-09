# KMS key for Secrets Manager
resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager (${var.project_name}-{var.project_environment})"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.secrets_kms_policy.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-secrets-cmk"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


data "aws_iam_policy_document" "secrets_kms_policy" {
  statement {
    sid    = "EnableRootPermissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

# The secret value - placeholder, not a real password
#checkov:skip=CKV2_AWS_57: Lab secret is not connected to a production database; automatic rotation Lambda is out of scope
resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.project_name}/${var.environment}/db-password"
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = 7

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-password"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

#reference the existing OIDC provider
data "aws_iam_openid_connect_provider" "eks" {
  url = "https://oidc.eks.${var.aws_region}.amazonaws.com/id/66F4B6DC9582BCFEE67BBCEE8E3ED1B7"
}

#IAM role that trusts the service account
resource "aws_iam_role" "secrets_sa" {

  name = "${var.project_name}-${var.environment}-secrets-sa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(data.aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:default:secrets-sa"
          "${replace(data.aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"

        }
      }
    }]
  })
  tags = {
    Name        = "${var.project_name}-${var.environment}-secrets-sa-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Permission to fetch the secret

resource "aws_iam_role_policy" "secrets_sa" {
  name = "${var.project_name}-${var.environment}-secrets-sa-policy"
  role = aws_iam_role.secrets_sa.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = [aws_secretsmanager_secret.db.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [aws_kms_key.secrets.arn]
    }]
  })
}
