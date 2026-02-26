terraform {
  backend "s3" {
    bucket  = "tfstate-657840741348-us-east-1"
    key     = "terraform-infrastructure/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
