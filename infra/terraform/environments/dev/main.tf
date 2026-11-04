

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

