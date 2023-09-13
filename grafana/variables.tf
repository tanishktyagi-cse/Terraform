variable "aws-region" {
  type        = string
  description = "Region"
}

variable "aws-profile" {
  type        = string
  description = "Profile"
}

variable "create-key" {
  type        = string
  description = "Wanna create key(y/n)"
}

variable "ec2-key" {
  type        = string
  description = "Key Name For Grafana Instance"
}

variable "project-name" {
  type        = string
  description = "Project name"
}

variable "environment-name" {
  type        = string
  description = "Environment name"
}

variable "vpc-id" {
  type        = string
  description = "Vpc ID"
}

variable "subnet-id" {
  type        = string
  description = "Subnet ID"
}

variable "iam-role" {
  type        = string
  description = "Enter IAM Role with cloudwatch full access permission to be attached with Instance. If not already created, leave it empty and terraform will create it for you"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

