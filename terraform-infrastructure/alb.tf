module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  environment        = var.environment
  security_group_ids = [aws_security_group.alb.id]
  subnet_ids         = [for s in aws_subnet.public : s.id]
  vpc_id             = aws_vpc.this.id
  log_bucket_id      = aws_s3_bucket.log_bucket.id
  target_port        = 3000
  health_check_path  = "/health"
}
