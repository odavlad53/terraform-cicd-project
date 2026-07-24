resource "aws_ecs_service" "this" {
  name             = "${var.project_name}-${var.environment}-service"
  cluster          = aws_ecs_cluster.this.id
  task_definition  = aws_ecs_task_definition.this.arn
  desired_count    = var.desired_count
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  # Enable ECS Exec (SSM) for container access
  enable_execute_command = var.enable_execute_command

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-service"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}