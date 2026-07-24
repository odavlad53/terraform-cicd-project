module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids = [for s in aws_subnet.private : s.id]

  security_group_ids = [
    aws_security_group.ecs_tasks.id
  ]

  target_group_arn = module.alb.target_group_arn

  container_name  = "${var.project_name}-app"
  container_port  = 3000
  container_image = "${aws_ecr_repository.this.repository_url}:latest"

  desired_count          = 2
  enable_execute_command = true

  db_secret_arn       = aws_secretsmanager_secret.db.arn
  secrets_kms_key_arn = aws_kms_key.secrets.arn

  depends_on = [
    module.alb
  ]

}
