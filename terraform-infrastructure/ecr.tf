#checkov:skip=CKV_AWS_136: Lab scope - avoid destructive ECR replacement for existing running service

data "aws_kms_key" "ecr_existing" {
  key_id = "arn:aws:kms:us-east-1:657840741348:key/d236850f-4fc3-4d3e-8038-48d157271195"
}

resource "aws_ecr_repository" "this" {
  name                 = "${var.project_name}-${var.environment}-app"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = data.aws_kms_key.ecr_existing.arn
  }

  tags = {
    Name        = "${var.project_name}-app"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
