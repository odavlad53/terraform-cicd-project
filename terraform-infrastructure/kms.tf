resource "aws_kms_key" "s3_key" {
  description         = "CMK for S3 (${var.project_name}-${var.environment})"
  enable_key_rotation = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-cmk"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/${var.project_name}-${var.environment}-s3"
  target_key_id = aws_kms_key.s3_key.key_id
}
