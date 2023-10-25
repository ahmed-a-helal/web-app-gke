module "architecture" {

  source              = "./modules"
  name_prefix         = var.name_prefix
  regions             = var.region
  cidr_subnet         = var.cidr_subnet
  helmdir             = var.helmdir
  kubernetisdir       = var.kubernetisdir
  dockerdir           = var.dockerdir
  database_image_name = var.database_image_name
  alpine_image_name   = var.alpine_image_name
  frontend_image_name = var.frontend_image_name
}
output "update_command" {
  value = module.architecture.update_command
}
output "ssh_command" {
  value = module.architecture.ssh_command
}
