variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "olga-project"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains (["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev,staging, or prod."
  }

}

variable "desired_count" {
    description = "Desired number of ECS tasks."
    type        = number
    default     = 2

    validation {
        condition     = var.desired_count >= 0
        error_message = "Desired count must be zero or greater." 
    }
}

variable "enable_execute_command" {
    description = "Whether ECS is enabled for the ECS service"
    type        = bool
    default     = true
}

variable "private_subnet_ids" {
    description = "Private subnet IDs used by ECS tasks."
    type        = list (string)
}


variable "security_group_ids" {
    description = "Security group IDs attached to ECS tasks"
    type        = list (string)
}

variable "target_group_arn" {
    description = "ARN of the ALB target group"
    type        = string
}

variable "container_name" {
    description = "Name of the container registered with the target group"
    type        = string
}

variable "container_image" {
    description = "Full container image URI, including its tag or digest."
    type        = string
}


variable "container_port" {
    description = "Port exposed by the application container."
    type        = number
    default     = 3000

    validation {
        condition     = var.container_port >= 1 && var.container_port <= 65535
        error_message = "Container port must be between 1 and 65535"
    }
}


variable "secrets_kms_key_arn" {
    description = "KMS key ARN used to encrypt ECS application secrets."
    type        = string
}

variable "db_secret_arn" {
    description  = "ARN of the database secret used by the ECS task."
    type         = string
}