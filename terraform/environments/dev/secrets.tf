
resource "aws_secretsmanager_secret" "database_url" {
  name        = "${local.name_prefix}/database/url"
  description = "PostgreSQL connection string for application services"

  recovery_window_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-database-url"
  })
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name        = "${local.name_prefix}/api-gateway/jwt-secret"
  description = "JWT signing secret for the API gateway"

  recovery_window_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-jwt-secret"
  })
}