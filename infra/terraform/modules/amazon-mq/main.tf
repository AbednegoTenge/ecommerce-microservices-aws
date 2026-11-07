

locals {
  name_prefix      = "${var.project_name}-${var.environment}"
  single_instance  = var.deployment_mode == "SINGLE_INSTANCE"
  broker_subnet_ids = local.single_instance ? [var.subnet_ids[0]] : var.subnet_ids
}

resource "random_password" "this" {
  length  = 24
  special = false 
}

resource "aws_security_group" "this" {
  name        = "${local.name_prefix}-mq-sg"
  description = "Security group for Amazon MQ RabbitMQ broker"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-mq-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "amqps" {
  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.allowed_security_group_id
  from_port                    = 5671
  to_port                      = 5671
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "console" {
  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.allowed_security_group_id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_mq_broker" "this" {
  broker_name        = "${local.name_prefix}-rabbitmq"
  engine_type        = "RabbitMQ"
  engine_version     = var.engine_version
  host_instance_type = var.instance_type
  deployment_mode    = var.deployment_mode

  subnet_ids          = local.broker_subnet_ids
  security_groups     = [aws_security_group.this.id]
  publicly_accessible = false

  auto_minor_version_upgrade = true
  apply_immediately          = var.apply_immediately

  user {
    username = var.username
    password = random_password.this.result
  }

  logs {
    general = true
  }

  tags = {
    Name = "${local.name_prefix}-rabbitmq"
  }
}

resource "aws_secretsmanager_secret" "this" {
  name                    = "${local.name_prefix}/rabbitmq"
  recovery_window_in_days = var.secret_recovery_days
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    AMQP_HOST     = local.broker_host
    AMQP_PORT     = "5671"
    AMQP_TLS      = "true"
    AMQP_USER     = var.username
    AMQP_PASSWORD = random_password.this.result
  })
}

locals {
  # endpoint looks like amqps://b-xxxx.mq.us-east-1.on.aws:5671
  broker_endpoint = aws_mq_broker.this.instances[0].endpoints[0]
  broker_host     = regex("^amqps://([^:]+):", local.broker_endpoint)[0]
}