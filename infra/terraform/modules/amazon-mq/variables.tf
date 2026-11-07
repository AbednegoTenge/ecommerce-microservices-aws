
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Data subnet IDs (only the first is used for SINGLE_INSTANCE)"
  type        = list(string)
}

variable "allowed_security_group_id" {
  description = "Security group allowed to connect (EKS cluster SG)"
  type        = string
}

variable "engine_version" {
  type    = string
  default = "3.13"
}

variable "instance_type" {
  type    = string
  default = "mq.t3.micro"
}

variable "deployment_mode" {
  type    = string
  default = "SINGLE_INSTANCE"

  validation {
    condition     = contains(["SINGLE_INSTANCE", "CLUSTER_MULTI_AZ"], var.deployment_mode)
    error_message = "deployment_mode must be SINGLE_INSTANCE or CLUSTER_MULTI_AZ."
  }
}

variable "username" {
  type    = string
  default = "robotshop"
}

variable "apply_immediately" {
  type    = bool
  default = true
}

variable "secret_recovery_days" {
  description = "0 deletes the secret immediately on destroy (dev); 7-30 for prod"
  type        = number
  default     = 0
}