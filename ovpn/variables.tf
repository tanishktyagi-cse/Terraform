variable "aws-region" {
  type        = string
  description = "Region"
}

variable "aws-profile" {
  type        = string
  description = "Profile"
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

variable "vpc-cidr" {
  type        = string
  description = "Vpc CIDR"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}
