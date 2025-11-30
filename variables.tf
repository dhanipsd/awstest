variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "ap-southeast-1"
}

variable "centos7_ami" {
  description = "CentOS 7 AMI ID (must be provided)"
  type        = string
}

variable "public_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "private_key_path" {
  description = "Path to SSH private key"
  type        = string
}
