terraform {
  backend "gcs" {
    bucket      = "iti_gke_terraform_state"
    # file path to the Service Account key used for the remote bucket access
    #credentials = "ahmed-attia-iti-terraform-bucket-access.json"
  }
}