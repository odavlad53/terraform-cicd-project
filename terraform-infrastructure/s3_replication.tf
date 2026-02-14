# trivy:ignore:AVD-AWS-0089  # lab: skipping server access logs
resource "aws_s3_bucket" "replica_bucket" {
  provider      = aws.replica
  bucket        = "${var.project_name}-${var.environment}-bucket-replica"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-bucket-replica"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "replica_bucket_pab" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "replica_bucket_versioning" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "replica_bucket_encryption" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_cmk.arn
    }
  }
}

data "aws_iam_policy_document" "s3_replication_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "s3_replication_role" {
  name               = "${var.project_name}-${var.environment}-s3-replication-role"
  assume_role_policy = data.aws_iam_policy_document.s3_replication_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-replication-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "s3_replication_policy" {
  #tfsec:ignore:aws-iam-no-policy-wildcards
  statement {
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.app_bucket.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]
    resources = ["${aws_s3_bucket.app_bucket.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    resources = ["${aws_s3_bucket.replica_bucket.arn}/*"]
  }
}

resource "aws_iam_role_policy" "s3_replication_role_policy" {
  name   = "${var.project_name}-${var.environment}-s3-replication-policy"
  role   = aws_iam_role.s3_replication_role.id
  policy = data.aws_iam_policy_document.s3_replication_policy.json
}

resource "aws_s3_bucket_replication_configuration" "app_bucket_replication" {
  depends_on = [
    aws_s3_bucket_versioning.app_bucket_versioning,
    aws_s3_bucket_versioning.replica_bucket_versioning
  ]

  bucket = aws_s3_bucket.app_bucket.id
  role   = aws_iam_role.s3_replication_role.arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica_bucket.arn
      storage_class = "STANDARD"
    }
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "replica_bucket_lifecycle" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica_bucket.id

  rule {
    id     = "abort-incomplete-mpu"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
