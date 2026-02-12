resource "aws_s3_bucket_lifecycle_configuration" "app_bucket_lifecycle" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {} # required by provider

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

