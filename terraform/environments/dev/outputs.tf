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

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded cluster CA certificate"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "EKS OIDC issuer URL"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "cluster_oidc_provider_arn" {
  description = "IAM OIDC provider ARN for IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "ebs_csi_role_arn" {
  description = "IRSA role ARN for the EBS CSI driver"
  value       = aws_iam_role.ebs_csi.arn
}

output "external_secrets_role_arn" {
  description = "IRSA role ARN for External Secrets Operator"
  value       = aws_iam_role.external_secrets.arn
}

output "app_irsa_role_arns" {
  description = "IRSA role ARNs for application services"
  value = {
    for name, role in aws_iam_role.app_sqs : name => role.arn
  }
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

output "sqs_order_events_queue_arn" {
  description = "SQS queue ARN for order events"
  value       = aws_sqs_queue.order_events.arn
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

output "github_actions_infra_role_arn" {
  description = "IAM role ARN for GitHub Actions Terraform / infra CI"
  value       = aws_iam_role.github_actions_infra.arn
}

output "github_actions_app_role_arn" {
  description = "IAM role ARN for GitHub Actions app build / ECR push"
  value       = aws_iam_role.github_actions_app.arn
}

output "eks_kms_key_arn" {
  description = "KMS key ARN used for EKS secrets encryption"
  value       = aws_kms_key.eks.arn
}

output "karpenter_interruption_queue_name" {
  description = "SQS queue used by Karpenter for interruption handling"
  value       = aws_sqs_queue.karpenter_interruption.name
}

output "karpenter_interruption_queue_arn" {
  description = "ARN of the Karpenter interruption queue"
  value       = aws_sqs_queue.karpenter_interruption.arn
}

output "karpenter_controller_role_arn" {
  description = "IRSA IAM role used by the Karpenter controller"
  value       = aws_iam_role.karpenter_controller.arn
}

output "karpenter_node_role_name" {
  description = "IAM role used by Karpenter-created nodes"
  value       = aws_iam_role.karpenter_node.name
}

output "karpenter_node_role_arn" {
  description = "ARN of the IAM role used by Karpenter-created nodes"
  value       = aws_iam_role.karpenter_node.arn
}

output "karpenter_node_instance_profile_name" {
  description = "Pre-created instance profile used by Karpenter nodes"
  value       = aws_iam_instance_profile.karpenter_node.name
}
output "aws_load_balancer_controller_role_arn" {
  description = "IRSA role used by the AWS Load Balancer Controller"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "aws_load_balancer_controller_policy_arn" {
  description = "IAM policy used by the AWS Load Balancer Controller"
  value       = aws_iam_policy.aws_load_balancer_controller.arn
}
output "worker_sqs_role_arn" {
  description = "IRSA role ARN used by the worker for SQS access"
  value       = aws_iam_role.app_sqs["worker"].arn
}
output "order_service_sqs_role_arn" {
  description = "IRSA role ARN used by order-service for SQS access"
  value       = aws_iam_role.app_sqs["order-service"].arn
}

output "notification_service_sqs_role_arn" {
  description = "IRSA role ARN used by notification-service for SQS access"
  value       = aws_iam_role.app_sqs["notification-service"].arn
}