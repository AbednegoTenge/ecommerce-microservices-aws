variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "alert_email" {
  description = "Email address that receives alarm and budget notifications"
  type        = string
}

variable "cluster_name" {
  type = string
}

variable "rds_instance_id" {
  type = string
}

variable "docdb_cluster_id" {
  type = string
}

variable "valkey_replication_group_id" {
  type = string
}

variable "valkey_num_nodes" {
  description = "Must match num_cache_clusters in the Valkey module"
  type        = number
  default     = 1
}

variable "mq_broker_name" {
  type = string
}

variable "cpu_threshold" {
  type    = number
  default = 80
}

variable "memory_threshold" {
  type    = number
  default = 80
}

variable "rds_free_storage_gb" {
  type    = number
  default = 2
}

variable "mq_backlog_threshold" {
  description = "Alert when more than this many orders are waiting in the queue"
  type        = number
  default     = 100
}

variable "enable_budget" {
  description = "Budgets are account-wide; enable in one environment only"
  type        = bool
  default     = true
}

variable "monthly_budget_usd" {
  type    = number
  default = 50
}