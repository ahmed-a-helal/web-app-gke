provider "google" {
  region      = var.region[0]
  project     = var.project
  # the path to the Service Account Key used by terrafrom to authenticate to gcp and authorize to create and delete the infra"
  # credentials = "ahmed-attia-iti-terraform-access.json"
}
