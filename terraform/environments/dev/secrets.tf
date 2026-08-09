resource "aws_kms_key" "secrets" {
  description             = "Secrets Manager encryption for ${local.name_prefix}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-secrets-kms"
  })
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${local.name_prefix}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

resource "aws_secretsmanager_secret" "database_url" {
  name        = "${local.name_prefix}/database/url"
  description = "PostgreSQL connection string for application services"

  recovery_window_in_days = 7
  kms_key_id              = aws_kms_key.secrets.arn

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-database-url"
  })
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name        = "${local.name_prefix}/api-gateway/jwt-secret"
  description = "JWT signing secret for the API gateway"

  recovery_window_in_days = 7
  kms_key_id              = aws_kms_key.secrets.arn

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-jwt-secret"
  })
}