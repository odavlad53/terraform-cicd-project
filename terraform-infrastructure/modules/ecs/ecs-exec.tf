# SSM permissions for ECS Exec — this is what allows you to shell into the container
resource "aws_iam_role_policy" "ecs_exec_ssm" {
  count = var.enable_execute_command ? 1:0

  name = "${var.project_name}-${var.environment}-ecs-exec-ssm"
  role = aws_iam_role.ecs_task.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowECSExecSSMChannels"
        Effect = "Allow"


        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}