#checkov:skip=CKV2_AWS_3:Single-account lab - org-wide GuardDuty requires org admin

resource "aws_guardduty_detector" "this" {
  enable = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-guardduty"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}