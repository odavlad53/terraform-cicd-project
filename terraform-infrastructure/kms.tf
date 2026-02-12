data "aws_caller_identity" "current" {}

resource "aws_kms_key" "s3_cmk" {
  description             = "${var.project_name}-${var.environment} S3 CMK"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  # Explicit key policy (required by Checkov CKV2_AWS_64)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccountRootAdmin"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowEC2RoleDecrypt"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_role.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-cmk"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "s3_cmk_alias" {
  name          = "alias/${var.project_name}-${var.environment}-s3-cmk"
  target_key_id = aws_kms_key.s3_cmk.key_id
}

