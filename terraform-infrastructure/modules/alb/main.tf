#checkov:skip=CKV2_AWS_20: Lab scope - HTTP only demo endpoint, no ACM certificate/domain for HTTPS redirect
#checkov:skip=CKV2_AWS_28: Lab scope - WAF not implemented for this exercise
resource "aws_lb" "this" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  access_logs {
    bucket  = var.log_bucket_id
    prefix  = "alb"
    enabled = true
  }

  drop_invalid_header_fields = true
  enable_deletion_protection = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

#checkov:skip=CKV_AWS_378: Lab scope - ECS app traffic behind ALB uses HTTP on internal target group
resource "aws_lb_target_group" "this" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    matcher             = "200"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-tg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

#checkov:skip=CKV_AWS_2: Lab scope - listener intentionally uses HTTP for public demo access
#checkov:skip=CKV_AWS_103: Lab scope - TLS policy not applicable because HTTPS listener is not used in this exercise
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}