
# Current AWS account information

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

# Karpenter interruption queue
#
# Receives EC2 and AWS Health interruption events so
# Karpenter can drain and replace affected nodes.


resource "aws_sqs_queue" "karpenter_interruption" {
  name                      = "${local.name_prefix}-karpenter-interruption"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-karpenter-interruption"
  })
}


# Karpenter interruption queue policy


data "aws_iam_policy_document" "karpenter_interruption_queue" {
  statement {
    sid    = "AllowEventBridge"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "events.amazonaws.com"
      ]
    }

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.karpenter_interruption.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:${data.aws_partition.current.partition}:events:${var.aws_region}:${data.aws_caller_identity.current.account_id}:rule/${local.name_prefix}-karpenter-*"
      ]
    }
  }

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "sqs:*"
    ]

    resources = [
      aws_sqs_queue.karpenter_interruption.arn
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false"
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "karpenter_interruption" {
  queue_url = aws_sqs_queue.karpenter_interruption.url
  policy    = data.aws_iam_policy_document.karpenter_interruption_queue.json
}


# Karpenter interruption event definitions


locals {
  karpenter_interruption_events = {
    spot_interruption = {
      description = "EC2 Spot interruption warnings"

      event_pattern = {
        source = [
          "aws.ec2"
        ]

        detail-type = [
          "EC2 Spot Instance Interruption Warning"
        ]
      }
    }

    rebalance_recommendation = {
      description = "EC2 instance rebalance recommendations"

      event_pattern = {
        source = [
          "aws.ec2"
        ]

        detail-type = [
          "EC2 Instance Rebalance Recommendation"
        ]
      }
    }

    instance_state_change = {
      description = "EC2 instance state changes"

      event_pattern = {
        source = [
          "aws.ec2"
        ]

        detail-type = [
          "EC2 Instance State-change Notification"
        ]
      }
    }

    scheduled_change = {
      description = "AWS Health scheduled instance changes"

      event_pattern = {
        source = [
          "aws.health"
        ]

        detail-type = [
          "AWS Health Event"
        ]
      }
    }
  }
}


# EventBridge rules


resource "aws_cloudwatch_event_rule" "karpenter_interruption" {
  for_each = local.karpenter_interruption_events

  name          = "${local.name_prefix}-karpenter-${each.key}"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-karpenter-${each.key}"
  })
}


# EventBridge targets
#
# Sends events matched by each rule to the Karpenter
# interruption SQS queue.
############################################################

resource "aws_cloudwatch_event_target" "karpenter_interruption" {
  for_each = local.karpenter_interruption_events

  rule      = aws_cloudwatch_event_rule.karpenter_interruption[each.key].name
  target_id = "KarpenterInterruptionQueue"
  arn       = aws_sqs_queue.karpenter_interruption.arn

  depends_on = [
    aws_sqs_queue_policy.karpenter_interruption
  ]
}

############################################################
# Karpenter security-group discovery tag
############################################################

resource "aws_ec2_tag" "karpenter_cluster_security_group" {
  resource_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id

  key   = "karpenter.sh/discovery"
  value = aws_eks_cluster.main.name
}