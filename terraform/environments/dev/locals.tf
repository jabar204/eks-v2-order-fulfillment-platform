locals {
  name_prefix  = "${var.project_name}-${var.environment}"
  cluster_name = "${local.name_prefix}-cluster"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "jabar204"
  }

  service_names = [
    "api-gateway",
    "order-service",
    "inventory-service",
    "payment-service",
    "notification-service",
    "shipping-service",
    "worker",
    "scheduler",
    "dashboard-api",
  ]

  # Services that need SQS access via IRSA (extend as apps land)
  sqs_irsa_services = [
    "worker",
    "order-service",
    "notification-service",
  ]
}
