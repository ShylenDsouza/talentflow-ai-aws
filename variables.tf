variable "aws_region" {
  type        = string
  default     = "eu-north-1"
  description = "Target AWS Region"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR block"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 application instance type"
}

variable "asg_min_size" {
  type    = number
  default = 2
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
}

variable "asg_max_size" {
  type    = number
  default = 4
}

variable "queue_alarm_threshold" {
  type        = number
  default     = 10
  description = "Queue depth alarm threshold"
}

variable "notification_email" {
  type        = string
  default     = "recruiter-alerts@talentflow.internal"
  description = "Recruiter notification email subscription"
}
