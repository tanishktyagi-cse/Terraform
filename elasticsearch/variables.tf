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
  validation {
    condition     = contains(["y", "n"], var.create-key)
    error_message = "Valid values for var: create-key are (y,n)."
  } 
}

variable "ec2-key" {
  type        = string
  description = "Key Name"
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

variable "vpc-cidr" {
    type = string
    description = "VPC CIDR"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "connectivity" {
    type = string
    description = "public/private"
    validation {
    condition     = contains(["public", "private"], var.connectivity)
    error_message = "Valid values for var: connectivity are (public, private)."
  } 
}

variable "antier_ips" {
    type = list
    default = ["112.196.25.234/32","182.73.149.42/32","112.196.81.250/32","125.21.216.158/32"]
    description = "Antier IPS"
}

variable "node-count" {
    type = number
    description = "Number of nodes to create"
}