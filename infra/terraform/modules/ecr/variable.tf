
variable "repository_names" {
  description = "List of ECR repository names"
  type = list(string)
}

variable "project_name" {
  description = "Name of the project"
  type = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type = string
}