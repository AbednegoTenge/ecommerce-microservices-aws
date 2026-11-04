variable "project_name" {
  description = "Project name used in resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "valkey_node_type" {
  type = string
}

variable "valkey_num_cache_clusters" {
  type = number
}

variable "valkey_transit_encryption" {
  type = bool
}

variable "valkey_snapshot_retention" {
  type = number
}

variable "valkey_apply_immediately" {
  type = bool
}