output "terraform_state_bucket" {
  description = "Terraform remote state bucket (S3 native lockfile; no DynamoDB table)"
  value       = aws_s3_bucket.terraform_state.bucket
}
