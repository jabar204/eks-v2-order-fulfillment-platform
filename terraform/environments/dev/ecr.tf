# ECR resources for the development environment.
locals {
  service_names = [
    "api-gateway",
    "order-service",
    "inventory-service",
    "payment-service",
    "notification-service",
    "shipping-service",
    "worker",
    "scheduler",
    "dashboard-api"
  ]
}

resource "aws_ecr_repository" "services" {
  for_each = toset(local.service_names)

  name                 = "${local.name_prefix}-${each.key}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-${each.key}"
    Service = each.key
  })
}