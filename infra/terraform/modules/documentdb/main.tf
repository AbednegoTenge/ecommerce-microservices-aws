locals {
    name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_docdb_cluster" "this" {
    cluster_identifier = "${local.name_prefix}-docdb-cluster"
    engine = "docdb"
    engine_version = "5.0.0"
    manage_master_user_password = true
    master_username = var.docdb_master_username
    storage_encrypted = true
    skip_final_snapshot = true
    deletion_protection = false
    backup_retention_period = 1
    db_subnet_group_name = aws_docdb_subnet_group.this.name
    vpc_security_group_ids = [aws_security_group.this.id]
    db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.this.name

    tags = {
        Name = "${local.name_prefix}-docdb-cluster"
    }
}

resource "aws_docdb_cluster_instance" "this" {
    identifier = "${local.name_prefix}-docdb-instance-${count.index}"
    cluster_identifier = aws_docdb_cluster.this.cluster_identifier
    instance_class     = var.instance_class
    count     = var.instance_count
    tags = {
        Name = "${local.name_prefix}-docdb-${count.index}"
    }
} 

resource "aws_docdb_subnet_group" "this" {
    name       = "${local.name_prefix}-docdb-subnet-group"
    subnet_ids = var.subnet_ids
}

resource "aws_security_group" "this" {
    name        = "${local.name_prefix}-docdb-sg"
    description = "Security group for DocumentDB cluster"
    vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "this" {
    security_group_id = aws_security_group.this.id
    from_port         = 27017
    to_port           = 27017
    ip_protocol          = "tcp"
    referenced_security_group_id = var.eks_security_group_id
}

resource "aws_docdb_cluster_parameter_group" "this" {
    name        = "${local.name_prefix}-docdb-parameter-group"
    family      = "docdb5.0"
    description = "Parameter group for DocumentDB cluster"

    parameter {
        name  = "tls"
        value = "disabled"
    }
}