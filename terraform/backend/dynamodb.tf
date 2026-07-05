resource "aws_dynamodb_table" "terraform_locks" {
  name         = "eks-v2-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project     = "eks-v2"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}