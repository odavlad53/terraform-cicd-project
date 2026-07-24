data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

data "aws_caller_identity" "current" {}

locals {
  detected_ip      = "${chomp(data.http.my_ip.response_body)}/32"
  eks_access_cidrs = length(var.eks_public_access_cidrs) > 0 ? var.eks_public_access_cidrs : [local.detected_ip]
}