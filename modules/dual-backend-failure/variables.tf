variable "subnet_id" {
  type        = string
  description = "ID of the public subnet"
}

variable "private_subnet_id" {
  type        = string
  description = "ID of the private subnet"
}

variable "security_group_id" {
  type        = string
  description = "ID of the security group"
}

variable "key_name" {
  type        = string
  description = "Name of the EC2 key pair"
}

variable "random_pet_id" {
  type        = string
  description = "Unique identifier for naming"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming resources"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the instances"
  default     = "ami-018ba43095ff50d08"  # Default to Amazon Linux 2 AMI
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "m6a.2xlarge"
}

variable "client_instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "m6a.2xlarge"
}


variable "instance_count" {
  type        = number
  description = "Number of EC2 instances to create"
  default     = 5
}

variable "private_key_pem" {
  type        = string
  description = "The private key content"
  sensitive   = true
}
variable "other_private_ips" {
  type        = list(string)
  description = "List of private IPs from the other module"
}

variable "other_public_ips" {
  type        = list(string)
  description = "List of public IPs from the other module"
}

variable "weka_version" {
  type        = string
  description = "Weka version"
  default     = "4.2.15"
}

variable "iam_role_name" {
  description = "Name of the IAM role for EC2 instances"
  type        = string
}

variable "iam_policy_arn" {
  description = "ARN of the IAM policy for describing instances"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile for EC2 instances"
  type        = string
}

variable "new_instance_count" {
  description = "new backends capable of having weka"
  type = number
  default = 2
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}
