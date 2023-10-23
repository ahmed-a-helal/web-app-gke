resource "google_artifact_registry_repository" "my-repo" {
  location      = var.region
  repository_id = "${var.name_prefix}-repo"
  description   = "This repo is maintained by terraformfrom for this project ${var.name_prefix}"
  format        = "DOCKER"
}