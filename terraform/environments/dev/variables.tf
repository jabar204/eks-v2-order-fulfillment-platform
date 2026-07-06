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