#checkov:skip=CKV_AWS_356:KMS key policy requires Resource "*" and is constrained by principals/conditions
#checkov:skip=CKV_AWS_109:KMS key policy admin/use statements are intentionally scoped by principal
#checkov:skip=CKV_AWS_111:KMS Encrypt/Decrypt are required; constraints are enforced via key policy principals
data "aws_iam_policy_document" "s3_key_policy" {
  # Admin: account root
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

  # Allow EC2 role to use the key for reading encrypted objects
  statement {
    sid    = "AllowUseForEC2Role"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ec2_role.arn]
    }

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }

  # Allow S3 server access logging service to encrypt log objects (log delivery)
  statement {
    sid    = "AllowS3LoggingService"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.app_bucket.arn]
    }
  }
}

resource "aws_kms_key" "s3_key" {
  description         = "CMK for S3 (${var.project_name}-${var.environment})"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.s3_key_policy.json

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
