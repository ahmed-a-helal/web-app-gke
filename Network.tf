module "network" {

  source = "./modules/network"

  project = var.project

  region = var.region

  name_prefix = var.name_prefix

  cidr_subnet = var.cidr_subnet

}