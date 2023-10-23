provider "google" {

  project     = var.project
  region      = var.region[0]
  credentials = "ahmed-attia-iti-terraform-access.json"

}
