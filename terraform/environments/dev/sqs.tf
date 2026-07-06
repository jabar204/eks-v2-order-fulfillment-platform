
resource "aws_sqs_queue" "order_events_dlq" {
  name = "${local.name_prefix}-order-events-dlq"

  message_retention_seconds = 1209600

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-order-events-dlq"
  })
}

resource "aws_sqs_queue" "order_events" {
  name = "${local.name_prefix}-order-events"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_events_dlq.arn
    maxReceiveCount     = 3
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-order-events"
  })
}