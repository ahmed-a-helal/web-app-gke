terraform {
  backend "gcs" {
    bucket      = "iti_gke_terraform_state"
    credentials = "ahmed-attia-iti-terraform-bucket-access.json"
  }
}