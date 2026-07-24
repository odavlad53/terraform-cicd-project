variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "eks_public_access_cidrs" {
  description = "CIDRs allowed to access EKS public endpoint"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for EKS"
  type        = list(string)
}