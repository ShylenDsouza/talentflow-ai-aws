# TalentFlow AI - AWS Cloud Implementation

AI-powered recruitment and talent management platform (Davine Technologies, region eu-north-1).

## Implementation status
| Layer | Status |
|---|---|
| VPC, subnets, Internet Gateway, S3 gateway endpoint | Deployed, console verified |
| S3 bucket talentflow-resumes-prod-storage (SSE-S3, Block Public Access) | Deployed, console verified |
| EventBridge rule, SQS queue, Lambda trigger | Deployed, console verified |
| SNS topic and subscription, CloudWatch queue-depth alarm | Deployed, console verified |
| Terraform configuration | init and validate succeed |
| EC2, ALB, Auto Scaling, RDS PostgreSQL | Design only (not deployed, to avoid cost) |
| Route 53, CloudFront, API Gateway | Design only |
| CloudTrail, AWS Config, Budgets | Design only |
| Docker, ECR, ECS/EKS | Roadmap |

## Architecture
Implemented event path: application event -> EventBridge (RESUME_UPLOADED) -> SQS -> Lambda talentflow-resume-processor; CloudWatch alarm on queue depth -> SNS recruiter notification.
Target request path (design): Users -> Route 53 -> CloudFront -> ALB -> EC2 Auto Scaling Group -> RDS PostgreSQL.
See redacted/architecture_diagram.png.

## Terraform files (terraform/)
| File | Contents |
| main.tf | Provider (hashicorp/aws ~> 5.0), region, default tags |
| variables.tf | Region, CIDR, instance type, ASG sizes, alarm threshold, notification e-mail |
| vpc_and_compute.tf | VPC, IGW, 4 subnets, S3 endpoint, public route table, S3 bucket + encryption + public-access block (no compute yet) |
| serverless_and_events.tf | SQS + policy, EventBridge rule + target, SNS topic + subscription, CloudWatch alarm |
| outputs.tf | vpc_id, s3_bucket_arn, sqs_queue_url, sns_topic_arn, cloudwatch_alarm_id |

## Usage
bash
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output


## Known gaps
- Lambda function and trigger exist in the console but are not in Terraform.
- The console VPC (4 private subnets, 6 route tables) is larger than the Terraform baseline (2 private subnets, 1 route table).
- Compute, database and edge tiers are specifications only.

## Security notes
Do not commit terraform.tfvars, *.tfstate or credentials; commit .terraform.lock.hcl. Resumes contain personal data - restrict access and follow your retention policy.

## Cost
No NAT Gateway; Free Tier-eligible sizing is specified for compute. Run terraform destroy after testing.
