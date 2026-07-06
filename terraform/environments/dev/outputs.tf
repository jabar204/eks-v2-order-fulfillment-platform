output "name_prefix" {
  description = "Common name prefix for dev resources"
  value       = local.name_prefix
}
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "ecr_repository_urls" {
  description = "ECR repository URLs for application services"
  value = {
    for service, repo in aws_ecr_repository.services :
    service => repo.repository_url
  }
}

output "sqs_order_events_queue_url" {
  description = "SQS queue URL for order events"
  value       = aws_sqs_queue.order_events.url
}

output "sqs_order_events_dlq_url" {
  description = "SQS dead-letter queue URL for failed order events"
  value       = aws_sqs_queue.order_events_dlq.url
}

output "secrets_database_url_arn" {
  description = "ARN of the Secrets Manager secret for the database URL"
  value       = aws_secretsmanager_secret.database_url.arn
}

output "secrets_jwt_secret_arn" {
  description = "ARN of the Secrets Manager secret for the JWT signing secret"
  value       = aws_secretsmanager_secret.jwt_secret.arn
}