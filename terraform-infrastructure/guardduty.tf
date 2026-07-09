resource "aws_guardduty_detector" "this" {
  #checkov:skip=CKV2_AWS_3: Single-account lab; AWS Organizations GuardDuty configuration is out of scope
  enable = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-guardduty"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}