resource "aws_guardduty_detector" "this" {
  enable = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-guardduty"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}