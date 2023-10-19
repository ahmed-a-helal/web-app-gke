module "iam" {

  source = "./modules/iam"

  project = var.project

  name_prefix = var.name_prefix

  service_account = [
    {
      id   = "no-permission"
      name = "instance with no permission"
    },
    {
      id   = "artifact-access"
      name = "instance with docker artifact access"
    }
  ]

  permissions = ["artifactregistry.dockerimages.get", "artifactregistry.dockerimages.list", "artifactregistry.repositories.downloadArtifacts"]

}