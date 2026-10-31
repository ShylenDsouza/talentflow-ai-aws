resource "aws_sqs_queue" "resume_queue" {
  name                       = "talentflow-resume-queue"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 300
}

resource "aws_cloudwatch_event_rule" "resume_upload_rule" {
  name        = "talentflow-resume-upload-rule"
  description = "Routes resume upload events to SQS processing queue"

  event_pattern = jsonencode({
    source      = ["talentflow.application"]
    detail-type = ["RESUME_UPLOADED"]
  })
}

resource "aws_cloudwatch_event_target" "sqs_target" {
  rule      = aws_cloudwatch_event_rule.resume_upload_rule.name
  target_id = "SendToSQS"
  arn       = aws_sqs_queue.resume_queue.arn
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.resume_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEventBridge"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.resume_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.resume_upload_rule.arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic" "recruiter_alerts" {
  name = "talentflow-recruiter-notifications"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.recruiter_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_cloudwatch_metric_alarm" "queue_depth_alarm" {
  alarm_name          = "talentflow-resume-queue-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Average"
  threshold           = var.queue_alarm_threshold
  alarm_description   = "Triggers recruiter notifications if resume queue depth exceeds 10 messages"
  alarm_actions       = [aws_sns_topic.recruiter_alerts.arn]

  dimensions = {
    QueueName = aws_sqs_queue.resume_queue.name
  }
}
