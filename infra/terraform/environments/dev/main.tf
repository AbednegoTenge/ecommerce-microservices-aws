

module "vpc" {
  source = "../../modules/vpc"
  project_name    = "ecommerce-microservices"
  environment     = "dev"
  vpc_cidr_block  = "10.0.0.0/16"
  az_count        = 2
}