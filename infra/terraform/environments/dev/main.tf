

module "vpc" {
  source = "../../modules/vpc"
  project_name    = "ecommerce-microservices"
  environment     = "dev"
  vpc_cidr_block  = "10.0.0.0/16"
  az_count        = 2
}

module "ecr" {
  source = "../../modules/ecr"
  project_name     = "ecommerce-microservices"
  environment      = "dev"
  repository_names = ["web", "catalogue", "cart", "user", "payment", "shipping", "ratings", "dispatch"]
}