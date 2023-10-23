module "architecture" {

  source      = "./modules"
  name_prefix = var.name_prefix
  regions     = var.region
  cidr_subnet = var.cidr_subnet

}
output "name" {
  value=module.architecture.update_command
}