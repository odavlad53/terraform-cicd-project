module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids = module.vpc.private_subnet_ids

  security_group_ids = [
    module.vpc.ecs_tasks_security_group_id
  ]

  target_group_arn = module.alb.target_group_arn

  container_name  = "${var.project_name}-app"
  container_port  = 3000
  container_image = "${module.ecr.repository_url}:latest"

  desired_count          = 2
  enable_execute_command = true

  db_secret_arn       = aws_secretsmanager_secret.db.arn
  secrets_kms_key_arn = aws_kms_key.secrets.arn

  depends_on = [
    module.alb
  ]

}
