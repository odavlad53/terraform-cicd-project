############################################
# IAM role + policy for EC2 (least privilege)
############################################

# IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# IAM policy for S3 access (read-only to our bucket)
# tfsec complains about the bucket/* object ARN wildcard; for "read any object in this bucket"
# that's expected. We keep it scoped to ONE bucket and document the exception.
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "${var.project_name}-${var.environment}-s3-readonly"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Read-only S3 access to ONLY this bucket
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.app_bucket.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.app_bucket.arn}/*"
        ]
      },

      # Required when the bucket uses SSE-KMS with your CMK
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [
          aws_kms_key.s3_key.arn
        ]
      }
    ]
  })
}

# Instance profile to attach role to EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-profile"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
