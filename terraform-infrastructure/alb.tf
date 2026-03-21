#checkov:skip=CKV2_AWS_20: Lab scope - HTTP only demo endpoint, no ACM certificate/domain for HTTPS redirect
#checkov:skip=CKV2_AWS_28: Lab scope - WAF not implemented for this exercise
resource "aws_lb" "this" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for s in aws_subnet.public : s.id]

  access_logs {
    bucket  = aws_s3_bucket.log_bucket.id
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
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
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
