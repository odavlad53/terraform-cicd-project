#---Unauthorized API Calls
resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "UnathorizedAPICalls"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"

  metric_transformation {
    name      = "UnauthorizedAPICalls"
    namespace = "CISBenchmark"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "UnauthorizedAPICalls"
  alarm_description   = "CIS 4.1 - Unauthorized API calls detected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnauthorizedAPICalls"
  namespace           = "CISBenchmark"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  tags = {
    Name        = "UnauthorizedAPICAlls"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_metric_filter" "security_group_changes" {
  name           = "SecurityGroupChanges"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ ($.eventName = \"AuthorizeSecurityGroupIngress\") || ($.eventName = \"AuthorizeSecurityGroupEgress\") || ($.eventName = \"RevokeSecurityGroupIngress\") || ($.eventName = \"RevokeSecurityGroupEgress\") || ($.eventName = \"CreateSecurityGroup\") || ($.eventName = \"DeleteSecurityGroup\") }"

  metric_transformation {
    name      = "SecurityGroupChanges"
    namespace = "CISBenchmark"
    value     = "1"
  }
}
resource "aws_cloudwatch_metric_alarm" "security_group_changes" {
  alarm_name          = "SecurityGroupChanges"
  alarm_description   = "CIS 4.2 - Security Group Changes"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "SecurityGroupChanges"
  namespace           = "CISBenchmark"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  tags = {
    Name        = "SecurityGroupChanges"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_metric_filter" "root_account_usage" {
  name           = "RootAccountUsage"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ ($.userIdentity.type = \"Root\") && ($.userIdentity.invokedBy NOT EXISTS) && ($.eventType != \"AwsServiceEvent\") }"

  metric_transformation {
    name      = "RootAccountUsage"
    namespace = "CISBenchmark"
    value     = "1"
  }
}
resource "aws_cloudwatch_metric_alarm" "root_account_usage" {
  alarm_name          = "RootAccountUsage"
  alarm_description   = "CIS 4.3 - Root Account Usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "RootAccountUsage"
  namespace           = "CISBenchmark"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  tags = {
    Name        = "RootAccountUsage"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_metric_filter" "console_login_without_mfa" {
  name           = "ConsoleLoginWithoutMFA"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") && ($.userIdentity.type = \"IAMUser\") }"

  metric_transformation {
    name      = "ConsoleLoginWithoutMFA"
    namespace = "CISBenchmark"
    value     = "1"
  }
}
resource "aws_cloudwatch_metric_alarm" "console_login_without_mfa" {
  alarm_name          = "ConsoleLoginWithoutMFA"
  alarm_description   = "CIS 4.4 - Root Account Usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ConsoleLoginWithoutMFA"
  namespace           = "CISBenchmark"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  tags = {
    Name        = "ConsoleLoginWithoutMFA"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}