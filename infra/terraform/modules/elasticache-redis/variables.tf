
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
  description = "Data subnet IDs"
  type        = list(string)
}

variable "allowed_security_group_id" {
  description = "Security group allowed to connect (EKS cluster SG)"
  type        = string
}

variable "engine_version" {
  type    = string
  default = "8.0"
}

variable "node_type" {
  type    = string
  default = "cache.t4g.micro"
}

variable "num_cache_clusters" {
  description = "1 = single node, 2+ = primary with replicas (enables failover and Multi-AZ)"
  type        = number
  default     = 1

  validation {
    condition     = var.num_cache_clusters >= 1 && var.num_cache_clusters <= 6
    error_message = "num_cache_clusters must be between 1 and 6."
  }
}

variable "transit_encryption_enabled" {
  type    = bool
  default = false
}

variable "snapshot_retention_limit" {
  description = "Days to keep backups (0 = no backups)"
  type        = number
  default     = 0
}

variable "apply_immediately" {
  type    = bool
  default = true
}