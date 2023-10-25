locals {
  repolink = join("/", [join("", [split("/", "${module.registry.id}")[3], "-docker.pkg.dev"]), split("/", "${module.registry.id}")[1], split("/", "${module.registry.id}")[5]])
  command  = <<EOF
    ./scripts/container_startup.sh  --zone "${module.compute.instance_zone}" --project "${data.google_client_config.self.project}" --dockerdir "${var.dockerdir}" --helmdir "${var.helmdir}"  --node "${module.compute.nodename}"      --region "${var.regions[1]}" --cluster "${module.compute.container_name}" --registry "${local.repolink}" --databaseimage "${var.database_image_name}" --webimage "${var.frontend_image_name}" --alpineimage "${var.alpine_image_name}"
    EOF 
}

module "network" {

  source      = "./network"
  name_prefix = var.name_prefix
  subnets = {
    instance = {
      name_suffix   = "control-subnet"
      ip_cidr_range = var.cidr_subnet[0]
      region        = var.regions[0]
    }
    kube = {
      name_suffix   = "kube"
      ip_cidr_range = var.cidr_subnet[1]
      region        = var.regions[1]
    }
  }

}
module "iam" {

  source      = "./iam"
  name_prefix = var.name_prefix
  service_accounts = {
    instance = {
      account_id = "kube-admin-tf"
      name       = "instance with kube and artifact perm"
      role_id    = "kube_admin"
      permissions = ["container.configMaps.create", "container.configMaps.delete", "container.configMaps.get", "container.configMaps.list", "container.configMaps.update"
        , "container.nodes.get", "container.nodes.list"
        , "container.pods.attach", "container.pods.create", "container.pods.delete", "container.pods.evict", "container.pods.exec", "container.pods.get", "container.pods.getLogs", "container.pods.getStatus", "container.pods.initialize", "container.pods.list", "container.pods.portForward", "container.pods.proxy", "container.pods.update", "container.pods.updateStatus"
        , "container.secrets.create", "container.secrets.delete", "container.secrets.get", "container.secrets.list", "container.secrets.update"
        , "container.services.create", "container.services.delete", "container.services.get", "container.services.getStatus", "container.services.list", "container.services.proxy", "container.services.update", "container.services.updateStatus"
        , "container.replicaSets.create", "container.replicaSets.delete", "container.replicaSets.get", "container.replicaSets.getScale", "container.replicaSets.getStatus", "container.replicaSets.list", "container.replicaSets.update", "container.replicaSets.updateScale", "container.replicaSets.updateStatus"
        , "container.statefulSets.create", "container.statefulSets.delete", "container.statefulSets.get", "container.statefulSets.getScale", "container.statefulSets.getStatus", "container.statefulSets.list", "container.statefulSets.update", "container.statefulSets.updateScale", "container.statefulSets.updateStatus"
        , "container.deployments.create", "container.deployments.delete", "container.deployments.get", "container.deployments.getScale", "container.deployments.getStatus", "container.deployments.list", "container.deployments.rollback", "container.deployments.update", "container.deployments.updateScale", "container.deployments.updateStatus"
        , "container.events.get", "container.events.list", "container.clusters.list", "container.clusters.get"
        , "container.persistentVolumeClaims.create", "container.persistentVolumeClaims.delete", "container.persistentVolumeClaims.get", "container.persistentVolumeClaims.getStatus", "container.persistentVolumeClaims.list", "container.persistentVolumeClaims.update", "container.persistentVolumeClaims.updateStatus"
        , "container.serviceAccounts.create", "container.serviceAccounts.createToken", "container.serviceAccounts.delete", "container.serviceAccounts.get", "container.serviceAccounts.list", "container.serviceAccounts.update"
      , "artifactregistry.repositories.uploadArtifacts"] #,"artifactregistry.repositories.update","artifactregistry.repositories.get"
      #,"artifactregistry.dockerimages.get","artifactregistry.dockerimages.list","artifactregistry.files.get","artifactregistry.files.list","artifactregistry.locations.get","artifactregistry.locations.list","artifactregistry.tags.create","artifactregistry.tags.delete","artifactregistry.tags.get","artifactregistry.tags.list","artifactregistry.tags.update"]
    }
    kube = {
      account_id  = "artifact-access-tf"
      name        = "instance with docker artifact access"
      role_id     = "artifact_access_tf"
      permissions = ["artifactregistry.repositories.downloadArtifacts", "artifactregistry.dockerimages.get", "artifactregistry.dockerimages.list", "artifactregistry.locations.get", "artifactregistry.locations.list"]
    }
  }
}

module "compute" {
  source                                = "./compute"
  name_prefix                           = var.name_prefix
  gke_subnet                            = module.network.subnets.subnets.kube.id
  management_node_subnet                = module.network.subnets.subnets.instance.id
  gke_service_account_email             = module.iam.service_accounts.kube.email
  management_node_service_account_email = module.iam.service_accounts.instance.email
  management_node_tags                  = [module.network.iap-tag, ]
}
module "registry" {
  source      = "./registry"
  name_prefix = var.name_prefix
  region      = var.regions[1]
}



resource "null_resource" "kubernetis_apply" {

  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [module.compute]

  provisioner "local-exec" {
    command = local.command
  }


}

output "update_command" {
  value = local.command
}
output "ssh_command" {
  value = "gcloud compute ssh --project ${data.google_client_config.self.project} --zone ${module.compute.instance_zone} --tunnel-through-iap  ${module.compute.nodename}  "
}
data "google_client_config" "self" {

}