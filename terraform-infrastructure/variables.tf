variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = ""
}

variable "eks_public_access_cidrs" {
  description = <<-EOT
    CIDRs for the EKS public API endpoint.
    []               → auto-detect caller IP (local dev)
    ["0.0.0.0/0"]   → open (CI/CD runners)
    ["x.x.x.x/32"]  → explicit list (VPN / office)
  EOT
  type        = list(string)
  default     = []
}

variable "alert_email" {
  description = "Email for security alerts"
  type        = string
  default     = ""
}
