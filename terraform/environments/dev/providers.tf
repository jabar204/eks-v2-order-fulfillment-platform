provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "eks-v2"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}