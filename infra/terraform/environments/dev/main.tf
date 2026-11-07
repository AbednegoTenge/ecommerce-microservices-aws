

module "vpc" {
  source = "../../modules/vpc"
  project_name    = var.project_name
  environment     = var.environment
  vpc_cidr_block  = "10.0.0.0/16"
  az_count        = 2
}

module "ecr" {
  source = "../../modules/ecr"
  project_name     = var.project_name
  environment      = var.environment
  repository_names = ["web", "catalogue", "cart", "user", "payment", "shipping", "ratings", "dispatch"]
}

module "eks" {
  source = "../../modules/eks"
  project_name = var.project_name
  environment  = var.environment
  subnet_ids   = module.vpc.private_subnet_ids
}

module "rds_mysql" {
  source = "../../modules/rds-mysql"
  project_name = var.project_name
  environment  = var.environment
  db_name      = "ecommerce_db"
  engine_version = "8.0.28"
  instance_class = "db.t3.medium"
  allocated_storage = 20
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.data_subnet_ids
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
  db_username  = "admin"
}

module "documentdb" {
  source = "../../modules/documentdb"
  project_name = var.project_name
  environment  = var.environment
  subnet_ids   = module.vpc.data_subnet_ids
  vpc_id       = module.vpc.vpc_id
  eks_security_group_id = module.eks.cluster_security_group_id
  docdb_master_username = "docdbadmin"
  instance_class = "db.t3.medium"
  instance_count = 2
}

module "valkey" {
  source                     = "../../modules/elasticache-redis"
  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.data_subnet_ids
  allowed_security_group_id  = module.eks.cluster_security_group_id

  node_type                  = var.valkey_node_type
  num_cache_clusters         = var.valkey_num_cache_clusters
  transit_encryption_enabled = var.valkey_transit_encryption
  snapshot_retention_limit   = var.valkey_snapshot_retention
  apply_immediately          = var.valkey_apply_immediately
}


module "amazon_mq" {
  source                    = "../../modules/amazon-mq"
  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.data_subnet_ids
  allowed_security_group_id = module.eks.cluster_security_group_id

  instance_type        = var.mq_instance_type
  deployment_mode      = var.mq_deployment_mode
  apply_immediately    = var.mq_apply_immediately
  secret_recovery_days = var.mq_secret_recovery_days
}