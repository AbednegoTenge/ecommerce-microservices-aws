output "db_address" {
  description = "Hostname of the MySQL database (without port)"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Port the database listens on"
  value       = aws_db_instance.this.port
}

output "db_endpoint" {
  description = "Hostname and port (host:3306)"
  value       = aws_db_instance.this.endpoint
}

output "db_name" {
  description = "Initial database name"
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "Master username"
  value       = aws_db_instance.this.username
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN holding the master password"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "security_group_id" {
  description = "Security group attached to the database"
  value       = aws_security_group.this.id
}

output "db_instance_id" {
  value = aws_db_instance.this.identifier
}