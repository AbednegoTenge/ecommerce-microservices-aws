output "broker_host" {
  value = local.broker_host
}

output "amqps_endpoint" {
  value = local.broker_endpoint
}

output "console_url" {
  value = aws_mq_broker.this.instances[0].console_url
}

output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "broker_name" {
  value = aws_mq_broker.this.broker_name
}