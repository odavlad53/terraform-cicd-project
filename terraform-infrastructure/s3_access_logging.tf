########################################
# Access logs bucket (PRIMARY region)
########################################

# checkov:skip=CKV_AWS_18: "Access logs bucket does not need to log itself for this lab"
# trivy:ignore:aws-s3-enable-logging
resource "aws_s3_bucket" "access_logs_bucket" {
  bucket        = "${var.project_name}-${var.environment}-access-logs"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-access-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs_bucket_pab" {
  bucket                  = aws_s3_bucket.access_logs_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs_bucket_encryption" {
  bucket = aws_s3_bucket.access_logs_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_cmk.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "access_logs_bucket_versioning" {
  bucket = aws_s3_bucket.access_logs_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs_bucket_lifecycle" {
  bucket = aws_s3_bucket.access_logs_bucket.id

  rule {
    id     = "expire-access-logs"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

########################################
# Enable access logging for APP bucket
########################################

resource "aws_s3_bucket_logging" "app_bucket_logging" {
  bucket        = aws_s3_bucket.app_bucket.id
  target_bucket = aws_s3_bucket.access_logs_bucket.id
  target_prefix = "app-bucket/"
}
########################################
# Access logs bucket (REPLICA region)
########################################

# checkov:skip=CKV_AWS_18: "Access logs bucket does not need to log itself for this lab"
# trivy:ignore:aws-s3-enable-logging
resource "aws_s3_bucket" "replica_access_logs_bucket" {
  provider      = aws.replica
  bucket        = "${var.project_name}-${var.environment}-access-logs-replica"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-access-logs-replica"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "replica_access_logs_bucket_pab" {
  provider                = aws.replica
  bucket                  = aws_s3_bucket.replica_access_logs_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "replica_access_logs_bucket_encryption" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica_access_logs_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_cmk.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "replica_access_logs_bucket_versioning" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica_access_logs_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "replica_access_logs_bucket_lifecycle" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replica_access_logs_bucket.id

  rule {
    id     = "expire-access-logs"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

########################################
# Enable access logging for REPLICA bucket
########################################

resource "aws_s3_bucket_logging" "replica_bucket_logging" {
  provider      = aws.replica
  bucket        = aws_s3_bucket.replica_bucket.id
  target_bucket = aws_s3_bucket.replica_access_logs_bucket.id
  target_prefix = "replica-bucket/"
}
