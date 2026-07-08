resource "aws_sns_topic" "security_alerts" {
  name              = "${var.project_name}-${var.environment}-security-alerts"
  kms_master_key_id = aws_kms_key.cloudtrail.arn
 
  tags = {
     Name           = "${var.project_name}-${var.environment}-security-alerts"
     Environment    = var.environment
     ManagedBy      = "Terraform"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
  }   

