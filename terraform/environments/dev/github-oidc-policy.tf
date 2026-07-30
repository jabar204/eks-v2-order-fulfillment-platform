# Least-privilege policies for split GitHub Actions roles

data "aws_iam_policy_document" "github_actions_app" {
  statement {
    sid       = "ECRAuthToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPull"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:ListImages",
    ]

    resources = [for repo in aws_ecr_repository.services : repo.arn]
  }

  statement {
    sid    = "EKSReadForDeploy"
    effect = "Allow"

    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
    ]

    resources = [aws_eks_cluster.main.arn]
  }
}

resource "aws_iam_policy" "github_actions_app" {
  name        = "${local.name_prefix}-github-actions-app"
  description = "ECR push/pull and EKS describe for app CI"
  policy      = data.aws_iam_policy_document.github_actions_app.json
  tags        = local.common_tags
}

resource "aws_iam_role_policy_attachment" "github_actions_app" {
  role       = aws_iam_role.github_actions_app.name
  policy_arn = aws_iam_policy.github_actions_app.arn
}

data "aws_iam_policy_document" "github_actions_infra" {
  statement {
    sid    = "TerraformState"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::eks-v2-terraform-state-jabar204",
      "arn:aws:s3:::eks-v2-terraform-state-jabar204/*",
    ]
  }

  statement {
    sid    = "ReadForPlan"
    effect = "Allow"

    actions = [
      "sts:GetCallerIdentity",
      "ec2:Describe*",
      "ec2:Get*",
      "eks:Describe*",
      "eks:List*",
      "iam:Get*",
      "iam:List*",
      "iam:GetOpenIDConnectProvider",
      "iam:ListOpenIDConnectProviders",
      "ecr:Describe*",
      "ecr:List*",
      "ecr:Get*",
      "sqs:Get*",
      "sqs:List*",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets",
      "secretsmanager:GetResourcePolicy",
      "kms:Describe*",
      "kms:Get*",
      "kms:List*",
      "logs:Describe*",
      "logs:ListTags*",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions_infra" {
  name        = "${local.name_prefix}-github-actions-infra"
  description = "State + read access for Terraform plan in CI"
  policy      = data.aws_iam_policy_document.github_actions_infra.json
  tags        = local.common_tags
}

resource "aws_iam_role_policy_attachment" "github_actions_infra" {
  role       = aws_iam_role.github_actions_infra.name
  policy_arn = aws_iam_policy.github_actions_infra.arn
}
