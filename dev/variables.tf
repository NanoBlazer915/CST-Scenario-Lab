variable "region" {
    default = "us-east-1"
}

variable "cidr_block" {
    default = "10.10.0.0/16"
}

variable "subnet_cidr" {
    default = "10.10.0.0/19"
}

variable "environment" {
    default = "CST-Scenario-lab"
}

variable "instance_count" {
  description = "The number of EC2 instances to create"
  type        = number
  default     = 6
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m6a.2xlarge"
}

variable "ami_id" {
  description = "AMI ID for the instances"
  type        = string
  default     = "ami-018ba43095ff50d08"  
}

variable "expiration_tag_key" {
  description = "Tag key to identify instances for auto-destruction"
  type        = string
  default     = "AutoDestroy"
}

variable "expiration_tag_value" {
  description = "Tag value to identify instances for auto-destruction"
  type        = string
  default     = "true"
}

variable "expiration_time" {
  description = "Time limit in hours after which instances should be destroyed"
  type        = number
  default     = 4
}
variable "s3_bucket_name" {
  description = "Name of the existing S3 bucket for Lambda code"
  type        = string
  default     = "cst-scenario-lab"  # Replace with your actual bucket name if it may vary
}
