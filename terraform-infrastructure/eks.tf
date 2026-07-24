module "eks" {
  source = "./modules/eks"

  project_name            = var.project_name
  environment             = var.environment
  aws_region              = var.aws_region
  eks_public_access_cidrs = var.eks_public_access_cidrs
  private_subnet_ids      = [for s in aws_subnet.private : s.id]
  public_subnet_ids       = [for s in aws_subnet.public : s.id]
}