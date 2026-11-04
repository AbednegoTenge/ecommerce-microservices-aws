locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_db_instance" "this" {
  identifier                  = "${local.name_prefix}-mysql"
  engine                      = "mysql"
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  storage_type                = "gp3"
  storage_encrypted           = true

  db_name                     = var.db_name
  username                    = var.db_username
  manage_master_user_password = true

  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.this.id]
  publicly_accessible         = false
  multi_az                    = false

  backup_retention_period     = 1
  skip_final_snapshot         = true
  deletion_protection         = false
  apply_immediately           = true

  tags = {
    Name = "${local.name_prefix}-mysql"
  }
}

resource "aws_db_subnet_group" "this" {
    name       = "${local.name_prefix}-db-subnet-group"
    subnet_ids = var.subnet_ids

    tags = {
        Name = "${local.name_prefix}-db-subnet-group"
    }
}

resource "aws_security_group" "this" {
    name        = "${local.name_prefix}-db-sg"
    description = "Security group for RDS MySQL instance"
    vpc_id      = var.vpc_id
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
    from_port         = 3306
    to_port           = 3306
    ip_protocol          = "tcp"
    security_group_id = aws_security_group.this.id
    referenced_security_group_id = var.eks_cluster_security_group_id
}