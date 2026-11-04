variable "db_name" {
  description = ""
  type = string
}

variable "engine_version" {
  description = ""
  type = string
}

variable "instance_class" {
  description = ""
  type = string
}

variable "allocated_storage" {
  description = ""
  type = number
}

variable "vpc_id" {
    description = "The VPC ID where the RDS instance will be deployed"
    type = string
}

variable "subnet_ids" {
    description = "List of subnet IDs for the RDS instance"
    type = list(string)
}

variable "project_name" {
    description = "Name of the project"
    type = string
}

variable "environment" {
    description = "The environment where the RDS instance will be deployed"
    type = string
}

variable "eks_cluster_security_group_id" {
    description = "The security group ID of the EKS cluster"
    type = string
}

variable "db_username" {
    description = "The master username for the RDS instance"
    type = string
}