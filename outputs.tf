output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.talentflow_vpc.id
}

output "s3_bucket_arn" {
  description = "ARN of the resume S3 bucket"
  value       = aws_s3_bucket.resumes.arn
}

output "sqs_queue_url" {
  description = "URL of the resume ingestion SQS queue"
  value       = aws_sqs_queue.resume_queue.url
}

output "sns_topic_arn" {
  description = "ARN of the recruiter SNS topic"
  value       = aws_sns_topic.recruiter_alerts.arn
}

output "cloudwatch_alarm_id" {
  description = "CloudWatch Alarm ID"
  value       = aws_cloudwatch_metric_alarm.queue_depth_alarm.id
}
