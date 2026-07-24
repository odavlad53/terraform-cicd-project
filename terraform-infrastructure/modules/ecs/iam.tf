# --- IAM: Task Execution Role (used by ECS agent to pull images and write logs) ---
# Used by ECS to pull images, write logs, and retrieve injected secrets.

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-task-execution-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "ecs_secrets" {
  name = "${var.project_name}-${var.environment}-ecs-secrets-policy"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadApplicationSecret"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = [
          var.db_secret_arn
        ]
      },
      {
        Sid    = "DecryptApplicationSecret"
        Effect = "Allow"

        Action = [
          "kms:Decrypt"
        ]

        Resource = [
          var.secrets_kms_key_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- IAM: Task Role (used by the application container + ECS Exec/SSM) ---
# Used by the application container and ECS Exec.

resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-task-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
