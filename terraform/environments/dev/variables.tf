variable "aws_region" {
  description = "AWS region for the dev environment"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "eks-v2"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "cluster_public_access_cidrs" {
  description = "CIDR ranges allowed to access the public EKS API endpoint. Prefer your public IP/32 in real use."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_retention_days" {
  description = "CloudWatch retention for EKS control-plane logs"
  type        = number
  default     = 30
}

variable "github_infra_subjects" {
  description = "Allowed OIDC sub claims for the infra (Terraform) role"
  type        = list(string)
  default = [
    "repo:jabar204/eks-v2-order-fulfillment-platform:ref:refs/heads/main",
    "repo:jabar204/eks-v2-order-fulfillment-platform:environment:dev",
  ]
}

variable "github_app_subjects" {
  description = "Allowed OIDC sub claims for the app (ECR/deploy) role"
  type        = list(string)
  default = [
    "repo:jabar204/eks-v2-order-fulfillment-platform:ref:refs/heads/main",
    "repo:jabar204/eks-v2-order-fulfillment-platform:environment:dev",
  ]
}
