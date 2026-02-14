resource "aws_sqs_queue" "s3_events" {
  name = "${var.project_name}-${var.environment}-s3-events"

  sqs_managed_sse_enabled = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-events"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


data "aws_iam_policy_document" "s3_to_sqs" {
  statement {
    sid = "AllowS3SendMessage"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.s3_events.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.app_bucket.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "s3_events_policy" {
  queue_url = aws_sqs_queue.s3_events.id
  policy    = data.aws_iam_policy_document.s3_to_sqs.json
}

resource "aws_s3_bucket_notification" "app_bucket_notifications" {
  bucket = aws_s3_bucket.app_bucket.id

  queue {
    queue_arn = aws_sqs_queue.s3_events.arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_sqs_queue_policy.s3_events_policy]
}

resource "aws_s3_bucket_notification" "replica_bucket_notifications" {
  bucket      = aws_s3_bucket.replica_bucket.id
  provider    = aws.replica
  eventbridge = true
}
