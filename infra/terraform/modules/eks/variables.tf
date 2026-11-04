

variable "project_name" {
  description = "Name of the project"
  type = string
}


variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type = list(string)
}

variable "version_number" {
  description = "EKS version"
  type = string
  default = "1.34"
}