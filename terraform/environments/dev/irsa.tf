# IRSA — EKS OIDC provider + roles for addons and application services

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-oidc"
  })
}

locals {
  eks_oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn
  eks_oidc_issuer_host  = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}

# ---------------------------------------------------------------------------
# Helper: IRSA trust policy for a namespace/service-account pair
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "irsa_assume" {
  for_each = {
    ebs_csi = {
      namespace = "kube-system"
      sa        = "ebs-csi-controller-sa"
    }
    external_secrets = {
      namespace = "external-secrets"
      sa        = "external-secrets"
    }
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.eks_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.sa}"]
    }
  }
}

# ---------------------------------------------------------------------------
# EBS CSI Driver
# ---------------------------------------------------------------------------

resource "aws_iam_role" "ebs_csi" {
  name               = "${local.name_prefix}-ebs-csi"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume["ebs_csi"].json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ebs-csi"
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# ---------------------------------------------------------------------------
# External Secrets Operator — read Secrets Manager
# ---------------------------------------------------------------------------

resource "aws_iam_role" "external_secrets" {
  name               = "${local.name_prefix}-external-secrets"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume["external_secrets"].json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-external-secrets"
  })
}

data "aws_iam_policy_document" "external_secrets" {
  statement {
    sid    = "ReadSecrets"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]

    resources = [
      aws_secretsmanager_secret.database_url.arn,
      aws_secretsmanager_secret.jwt_secret.arn,
    ]
  }

  statement {
    sid       = "ListSecrets"
    effect    = "Allow"
    actions   = ["secretsmanager:ListSecrets"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_secrets" {
  name        = "${local.name_prefix}-external-secrets"
  description = "Allow External Secrets Operator to read app secrets"
  policy      = data.aws_iam_policy_document.external_secrets.json
  tags        = local.common_tags
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}

# ---------------------------------------------------------------------------
# Application IRSA — SQS access for worker / order / notification
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "app_sqs_assume" {
  for_each = toset(local.sqs_irsa_services)

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.eks_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_host}:sub"
      values   = ["system:serviceaccount:${each.key}:${each.key}"]
    }
  }
}

resource "aws_iam_role" "app_sqs" {
  for_each = toset(local.sqs_irsa_services)

  name               = "${local.name_prefix}-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.app_sqs_assume[each.key].json

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-${each.key}"
    Service = each.key
  })
}

data "aws_iam_policy_document" "app_sqs" {
  statement {
    sid    = "SQSAccess"
    effect = "Allow"

    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility",
    ]

    resources = [
      aws_sqs_queue.order_events.arn,
      aws_sqs_queue.order_events_dlq.arn,
    ]
  }
}

resource "aws_iam_policy" "app_sqs" {
  name        = "${local.name_prefix}-app-sqs"
  description = "SQS access for order-fulfillment services"
  policy      = data.aws_iam_policy_document.app_sqs.json
  tags        = local.common_tags
}

resource "aws_iam_role_policy_attachment" "app_sqs" {
  for_each = toset(local.sqs_irsa_services)

  role       = aws_iam_role.app_sqs[each.key].name
  policy_arn = aws_iam_policy.app_sqs.arn
}
