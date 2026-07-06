terraform {
  backend "s3" {
    bucket       = "eks-v2-terraform-state-jabar204"
    key          = "environments/dev/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
    encrypt      = true
  }
}