resource "aws_kms_key" "s3_cmk" {
  description             = "${var.project_name}-${var.environment} S3 CMK"
  deletion_window_in_days = 7
  enable_key_rotation     = true

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
