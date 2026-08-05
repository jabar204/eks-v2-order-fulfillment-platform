############################################################
# Karpenter IAM
#
# Creates:
# - IAM role for EC2 nodes launched by Karpenter
# - Pre-created instance profile for private-cluster use
# - EKS access entry allowing nodes to join the cluster
# - IRSA role for the Karpenter controller
# - Controller permissions for EC2, EKS, SQS, SSM and IAM
############################################################

############################################################
# Karpenter node trust policy
############################################################

data "aws_iam_policy_document" "karpenter_node_assume_role" {
  statement {
    sid    = "AllowEC2AssumeRole"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

############################################################
# Karpenter node IAM role
#
# This role is assumed by EC2 instances created by Karpenter.
############################################################

resource "aws_iam_role" "karpenter_node" {
  name               = "${local.name_prefix}-karpenter-node-role"
  assume_role_policy = data.aws_iam_policy_document.karpenter_node_assume_role.json

  tags = merge(local.common_tags, {
    Name                     = "${local.name_prefix}-karpenter-node-role"
    "karpenter.sh/discovery" = aws_eks_cluster.main.name
  })
}

############################################################
# Karpenter node managed policies
############################################################

resource "aws_iam_role_policy_attachment" "karpenter_worker_node" {
  role = aws_iam_role.karpenter_node.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_ecr_pull" {
  role = aws_iam_role.karpenter_node.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "karpenter_cni" {
  role = aws_iam_role.karpenter_node.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "karpenter_ssm" {
  role = aws_iam_role.karpenter_node.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

############################################################
# Karpenter node instance profile
#
# We create this ourselves because the platform is designed
# without NAT gateways. IAM has no VPC endpoint, so allowing
# Karpenter to create instance profiles at runtime would
# require public IAM API access.
############################################################

resource "aws_iam_instance_profile" "karpenter_node" {
  name = "${local.name_prefix}-karpenter-node-profile"
  role = aws_iam_role.karpenter_node.name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-karpenter-node-profile"
  })
}

############################################################
# EKS access entry for Karpenter nodes
#
# EC2_LINUX authorises Linux nodes using the Karpenter node
# role to authenticate and register with the EKS cluster.
############################################################

resource "aws_eks_access_entry" "karpenter_nodes" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.karpenter_node.arn
  type          = "EC2_LINUX"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-karpenter-node-access"
  })

  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.karpenter_worker_node,
    aws_iam_role_policy_attachment.karpenter_ecr_pull,
    aws_iam_role_policy_attachment.karpenter_cni
  ]
}

############################################################
# Karpenter controller IRSA trust policy
#
# Only this exact Kubernetes identity can assume the role:
#
# namespace:      kube-system
# serviceaccount: karpenter
############################################################

data "aws_iam_policy_document" "karpenter_controller_assume_role" {
  statement {
    sid    = "AllowKarpenterServiceAccount"
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.eks.arn
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test = "StringEquals"

      variable = "${replace(
        aws_iam_openid_connect_provider.eks.url,
        "https://",
        ""
      )}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test = "StringEquals"

      variable = "${replace(
        aws_iam_openid_connect_provider.eks.url,
        "https://",
        ""
      )}:sub"

      values = [
        "system:serviceaccount:kube-system:karpenter"
      ]
    }
  }
}

############################################################
# Karpenter controller IAM role
############################################################

resource "aws_iam_role" "karpenter_controller" {
  name               = "${local.name_prefix}-karpenter-controller-role"
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role.json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-karpenter-controller-role"
  })
}

############################################################
# Karpenter controller permissions
############################################################

data "aws_iam_policy_document" "karpenter_controller" {

  ##########################################################
  # Discover available EC2 capacity and networking
  ##########################################################

  statement {
    sid    = "AllowRegionalEC2ReadActions"
    effect = "Allow"

    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeCapacityReservations",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribePlacementGroups",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"

      values = [
        var.aws_region
      ]
    }
  }

  ##########################################################
  # Use AMIs, snapshots, subnets and security groups when
  # launching EC2 capacity.
  ##########################################################

  statement {
    sid    = "AllowScopedEC2InstanceAccess"
    effect = "Allow"

    actions = [
      "ec2:CreateFleet",
      "ec2:RunInstances"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}::image/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}::snapshot/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:*:security-group/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:*:subnet/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:*:capacity-reservation/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:*:placement-group/*"
    ]
  }

  ##########################################################
  # Launch instances using Karpenter-owned launch templates.
  ##########################################################

  statement {
    sid    = "AllowScopedLaunchTemplateUse"
    effect = "Allow"

    actions = [
      "ec2:CreateFleet",
      "ec2:RunInstances"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:launch-template/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"

      values = [
        "owned"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"

      values = [
        "*"
      ]
    }
  }

  ##########################################################
  # Create launch templates and instances with the required
  # cluster and NodePool tags.
  ##########################################################

  statement {
    sid    = "AllowScopedEC2ResourceCreation"
    effect = "Allow"

    actions = [
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate",
      "ec2:RunInstances"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:fleet/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:launch-template/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:spot-instances-request/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:volume/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"

      values = [
        "owned"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"

      values = [
        aws_eks_cluster.main.name
      ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.sh/nodepool"

      values = [
        "*"
      ]
    }
  }

  ##########################################################
  # Apply tags while EC2 creates Karpenter resources.
  ##########################################################

  statement {
    sid    = "AllowScopedEC2ResourceTaggingOnCreation"
    effect = "Allow"

    actions = [
      "ec2:CreateTags"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:fleet/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:launch-template/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:network-interface/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:spot-instances-request/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:volume/*"
    ]

    condition {
      test = "StringEquals"

      variable = "ec2:CreateAction"

      values = [
        "CreateFleet",
        "CreateLaunchTemplate",
        "RunInstances"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"

      values = [
        "owned"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.sh/nodepool"

      values = [
        "*"
      ]
    }
  }

  ##########################################################
  # Update tags on existing Karpenter-managed instances.
  ##########################################################

  statement {
    sid    = "AllowScopedEC2InstanceTagging"
    effect = "Allow"

    actions = [
      "ec2:CreateTags"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"

      values = [
        "owned"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"

      values = [
        "*"
      ]
    }
  }

  ##########################################################
  # Delete only resources belonging to this cluster and a
  # Karpenter NodePool.
  ##########################################################

  statement {
    sid    = "AllowScopedEC2Deletion"
    effect = "Allow"

    actions = [
      "ec2:DeleteLaunchTemplate",
      "ec2:TerminateInstances"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:launch-template/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"

      values = [
        "owned"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"

      values = [
        "*"
      ]
    }
  }

  ##########################################################
  # Allow EC2 to receive the pre-created Karpenter node role.
  ##########################################################

  statement {
    sid    = "AllowPassingKarpenterNodeRole"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      aws_iam_role.karpenter_node.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = [
        "ec2.amazonaws.com"
      ]
    }
  }

  ##########################################################
  # Read the pre-created instance profile.
  ##########################################################

  statement {
    sid    = "AllowInstanceProfileRead"
    effect = "Allow"

    actions = [
      "iam:GetInstanceProfile"
    ]

    resources = [
      aws_iam_instance_profile.karpenter_node.arn
    ]
  }

  statement {
    sid    = "AllowInstanceProfileList"
    effect = "Allow"

    actions = [
      "iam:ListInstanceProfiles"
    ]

    resources = ["*"]
  }

  ##########################################################
  # Resolve EKS-optimised AMIs through SSM.
  ##########################################################

  statement {
    sid    = "AllowSSMRead"
    effect = "Allow"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ssm:${var.aws_region}::parameter/aws/service/*"
    ]
  }

  ##########################################################
  # Read current EC2 pricing information.
  ##########################################################

  statement {
    sid    = "AllowPricingRead"
    effect = "Allow"

    actions = [
      "pricing:GetProducts"
    ]

    resources = ["*"]
  }

  ##########################################################
  # Discover the EKS API endpoint and cluster information.
  ##########################################################

  statement {
    sid    = "AllowEKSClusterDiscovery"
    effect = "Allow"

    actions = [
      "eks:DescribeCluster"
    ]

    resources = [
      aws_eks_cluster.main.arn
    ]
  }

  ##########################################################
  # Consume interruption notifications.
  ##########################################################

  statement {
    sid    = "AllowInterruptionQueueAccess"
    effect = "Allow"

    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage"
    ]

    resources = [
      aws_sqs_queue.karpenter_interruption.arn
    ]
  }
}

############################################################
# Karpenter controller managed policy
############################################################

resource "aws_iam_policy" "karpenter_controller" {
  name        = "${local.name_prefix}-karpenter-controller-policy"
  description = "Permissions used by the Karpenter controller"
  policy      = data.aws_iam_policy_document.karpenter_controller.json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-karpenter-controller-policy"
  })
}

############################################################
# Attach controller permissions to the IRSA role
############################################################

resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}