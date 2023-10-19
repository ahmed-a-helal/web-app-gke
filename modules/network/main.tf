resource "google_compute_network" "vpc" {

  name = "${var.name_prefix}-vpc"

  description = var.vpc_description

  # To create only the needed subnets
  auto_create_subnetworks = "false"

  project = var.project

  delete_default_routes_on_create = true

  routing_mode = "REGIONAL"

}
resource "google_compute_subnetwork" "eks-control-subnet" {

  name = "${var.name_prefix}-eks-control-subnet"

  ip_cidr_range = var.cidr_subnet

  region = var.region

  network = google_compute_network.vpc.id
}

resource "google_compute_router" "nat-router" {
  name = "${var.name_prefix}-nat-router"

  region = google_compute_subnetwork.eks-control-subnet.region

  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {

  name = "${var.name_prefix}-nat-route"

  router = google_compute_router.nat-router.name

  region = google_compute_router.nat-router.region

  nat_ip_allocate_option = "AUTO_ONLY"

  # To use the NAT gateway only with eks control subnet
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.eks-control-subnet.id
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGES"]
  }
}