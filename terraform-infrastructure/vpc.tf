# Fetch available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_key" "vpc_flow_logs" {
  description         = "CMK for VPC Flow Logs (${var.project_name}-${var.environment})"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogsUseOfKey"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/vpc-flow-logs/${var.project_name}-${var.environment}"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-flow-logs-kms"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "vpc_flow_logs" {
  name          = "alias/${var.project_name}-${var.environment}-vpc-flow-logs"
  target_key_id = aws_kms_key.vpc_flow_logs.key_id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/vpc-flow-logs/${var.project_name}-${var.environment}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.vpc_flow_logs.arn

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-flow-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name               = "${var.project_name}-${var.environment}-vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-flow-logs-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "${var.project_name}-${var.environment}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowWriteToSpecificFlowLogGroup"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
        ]
      }
    ]
  })
}

resource "aws_flow_log" "vpc" {
  vpc_id               = aws_vpc.this.id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-flow-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  ingress = []
  egress  = []

  tags = {
    Name        = "${var.project_name}-${var.environment}-default-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Internet Gateway — required for the public subnets
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# --- Public Subnets (for ALB and NAT Gateway) ---
resource "aws_subnet" "public" {
  #checkov:skip=CKV_AWS_130: Public subnets must auto-assign public IPs for ALB/NAT Gateway placement
  for_each = toset(local.azs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.key == local.azs[0] ? "10.0.1.0/24" : "10.0.2.0/24"
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name                                                           = "${var.project_name}-${var.environment}-public-${each.key}"
    Environment                                                    = var.environment
    ManagedBy                                                      = "Terraform"
    "kubernetes.io/role/elb"                                       = "1"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "shared"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# --- NAT Gateway (allows private subnets to reach the internet) ---

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-eip"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[local.azs[0]].id

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_internet_gateway.this]
}

# --- Private Subnets (for ECS tasks) ---

resource "aws_subnet" "private" {
  for_each = toset(local.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.key == local.azs[0] ? "10.0.10.0/24" : "10.0.20.0/24"
  availability_zone = each.key

  tags = {
    Name                                                           = "${var.project_name}-${var.environment}-private-${each.key}"
    Environment                                                    = var.environment
    ManagedBy                                                      = "Terraform"
    "kubernetes.io/role/internal-elb"                              = "1"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "shared"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-rt"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
