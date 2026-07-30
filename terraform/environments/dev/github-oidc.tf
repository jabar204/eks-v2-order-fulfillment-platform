# GitHub Actions OIDC — separate infra (Terraform) and app (ECR) roles

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # GitHub Actions OIDC root CA thumbprint (AWS also validates the cert chain).
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-github-oidc"
  })
}

data "aws_iam_policy_document" "github_infra_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.github_infra_subjects
    }
  }
}

data "aws_iam_policy_document" "github_app_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.github_app_subjects
    }
  }
}

resource "aws_iam_role" "github_actions_infra" {
  name               = "${local.name_prefix}-github-actions-infra"
  assume_role_policy = data.aws_iam_policy_document.github_infra_assume.json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-github-actions-infra"
    Role = "infra"
  })
}

resource "aws_iam_role" "github_actions_app" {
  name               = "${local.name_prefix}-github-actions-app"
  assume_role_policy = data.aws_iam_policy_document.github_app_assume.json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-github-actions-app"
    Role = "app"
  })
}
