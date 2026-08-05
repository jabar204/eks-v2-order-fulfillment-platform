############################################################
# AWS Load Balancer Controller IAM policy
#
# The permission document is downloaded from the controller's
# official repository and stored locally for reproducibility.
############################################################

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name = "${local.name_prefix}-aws-load-balancer-controller-policy"

  description = "Permissions used by the AWS Load Balancer Controller"

  policy = file(
    "${path.module}/policies/aws-load-balancer-controller-policy.json"
  )

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aws-load-balancer-controller-policy"
  })
}

############################################################
# IRSA trust policy
#
# Only this Kubernetes identity may assume the IAM role:
#
# Namespace:      kube-system
# ServiceAccount: aws-load-balancer-controller
############################################################

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role" {
  statement {
    sid    = "AllowAWSLoadBalancerControllerServiceAccount"
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
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
      ]
    }
  }
}

############################################################
# Controller IAM role
############################################################

resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "${local.name_prefix}-aws-load-balancer-controller-role"

  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role.json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aws-load-balancer-controller-role"
  })
}

############################################################
# Attach controller permissions to the IRSA role
############################################################

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role = aws_iam_role.aws_load_balancer_controller.name

  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}