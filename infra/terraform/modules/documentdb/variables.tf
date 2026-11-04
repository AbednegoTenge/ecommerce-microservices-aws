
variable "project_name" {
    description = "value"
    type        = string
}

variable "environment" {
    description = "value"
    type        = string
}

variable "subnet_ids" {
    description = "value"
    type        = list(string)
}

variable "vpc_id" {
    description = "value"
    type        = string
}

variable "eks_security_group_id" {
    description = "value"
    type        = string
}

variable "docdb_master_username" {
    description = "value"
    type        = string
}

variable "instance_class" {
    description = "value"
    type        = string
}

variable "instance_count" {
    description = "value"
    type        = number
}