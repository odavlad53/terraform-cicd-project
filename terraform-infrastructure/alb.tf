module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  environment        = var.environment
  security_group_ids = [module.vpc.alb_security_group_id]
  subnet_ids         = module.vpc.public_subnet_ids
  vpc_id             = module.vpc.vpc_id
  log_bucket_id      = aws_s3_bucket.log_bucket.id
  target_port        = 3000
  health_check_path  = "/health"
}
