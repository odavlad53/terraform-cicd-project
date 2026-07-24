# --- Task Definition ---

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-${var.environment}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                      = 256
  memory                   = 512

  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = [
          "CMD-SHELL",
          "curl -f http://localhost:3000/health || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }

      # Recommended for ECS Exec process cleanup
      linuxParameters = {
        initProcessEnabled = true
      }

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        }
      ]
    }
  ])

  tags = {
    Name        = "${var.project_name}-${var.environment}-task-def"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}