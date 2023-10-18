resource "google_compute_network" "vpc" {

  name = "${var.name_prefix}-vpc"

  description = "This VPC is managed by terraform"

  # To create only the needed subnets
  auto_create_subnetworks = "false"

  routing_mode = "REGIONAL"

}
resource "google_compute_subnetwork" "private_subnetwork" {

  name = "${var.name_prefix}-subnet"

  ip_cidr_range = var.cidr_subnet

  network = google_compute_network.vpc.id
}