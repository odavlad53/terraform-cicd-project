locals {
  ecs_log_group_name = "/ecs/${var.project_name}-${var.environment}"
}


resource "aws_kms_key" "ecs_logs" {
  description             = "KMS key for ECS CloudWatch Logs (${var.project_name}-${var.environment})"
  enable_key_rotation     = true
  deletion_window_in_days = 7

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
        Sid    = "AllowCloudWatchLogsUseOfKey"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.ecs_log_group_name}"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-logs-kms"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "ecs_logs" {
  name          = "alias/${var.project_name}-${var.environment}-ecs-logs"
  target_key_id = aws_kms_key.ecs_logs.key_id
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = local.ecs_log_group_name
  retention_in_days = 365
  kms_key_id        = aws_kms_key.ecs_logs.arn

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}