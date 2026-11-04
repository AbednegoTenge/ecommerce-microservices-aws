locals {
  name_prefix = "${var.project_name}-${var.environment}"
  ha_enabled  = var.num_cache_clusters > 1
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${local.name_prefix}-cache-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${local.name_prefix}-cache-subnet-group"
  }
}

resource "aws_security_group" "this" {
  name        = "${local.name_prefix}-cache-sg"
  description = "Security group for ElastiCache Valkey"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-cache-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.allowed_security_group_id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${local.name_prefix}-valkey"
  description          = "Valkey for cart and user services"

  engine         = "valkey"
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = 6379

  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = local.ha_enabled
  multi_az_enabled           = local.ha_enabled

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.this.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = var.transit_encryption_enabled

  snapshot_retention_limit = var.snapshot_retention_limit
  apply_immediately        = var.apply_immediately

  tags = {
    Name = "${local.name_prefix}-valkey"
  }
}