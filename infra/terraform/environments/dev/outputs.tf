output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "mysql_address" {
  value = module.rds_mysql.db_address
}

output "mysql_secret_arn" {
  value = module.rds_mysql.master_user_secret_arn
}