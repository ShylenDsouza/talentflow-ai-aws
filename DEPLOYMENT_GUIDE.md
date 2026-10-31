# TalentFlow AI - Deployment Guide (Terraform baseline)

## Prerequisites
Terraform >= 1.5, AWS CLI v2, a non-root IAM user or SSO role with MFA, region `eu-north-1`.

## Steps
1. `aws sts get-caller-identity` - confirm the account.
2. Set `notification_email` (variable default is a placeholder).
3. `terraform init` - installs hashicorp/aws ~> 5.0 and writes `.terraform.lock.hcl`.
4. `terraform validate` - expect "Success! The configuration is valid."
5. `terraform plan -out=tfplan` - review the 20 resources. Import or remove any resources already created by hand (for example the S3 bucket).
6. `terraform apply tfplan`, then `terraform output`.
7. Confirm the SNS subscription e-mail; publish a test `RESUME_UPLOADED` event (source `talentflow.application`); check the alarm in CloudWatch.
8. Teardown: `terraform destroy`; check for orphaned resources.

## Not covered by this configuration
Lambda function and trigger, EC2/ALB/Auto Scaling, RDS, Route 53, CloudFront, API Gateway, CloudTrail, AWS Config and Budgets are not in the Terraform files.
