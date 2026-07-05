output "terraform_state_bucket" {
  description = "Terraform remote state bucket"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_lock_table" {
  description = "Terraform state lock table"
  value       = aws_dynamodb_table.terraform_locks.name
}