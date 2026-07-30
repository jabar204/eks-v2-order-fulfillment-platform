# EKS control-plane log group must exist before the cluster creates it.
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_days

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-logs"
  })
}

resource "aws_kms_key" "eks" {
  description             = "EKS secrets encryption for ${local.cluster_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-kms"
  })
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${local.cluster_name}"
  target_key_id = aws_kms_key.eks.key_id
}

resource "aws_eks_cluster" "main" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  vpc_config {
    subnet_ids = module.vpc.private_subnets

    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.cluster_public_access_cidrs
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_cloudwatch_log_group.eks,
  ]

  tags = merge(local.common_tags, {
    Name = local.cluster_name
  })
}

resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.name_prefix}-system"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = module.vpc.private_subnets

  version       = var.kubernetes_version
  ami_type      = "AL2023_x86_64_STANDARD"
  capacity_type = "ON_DEMAND"

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "system"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only,
  ]

  tags = merge(local.common_tags, {
    Name                     = "${local.name_prefix}-system-node-group"
    "karpenter.sh/discovery" = local.cluster_name
  })
}
