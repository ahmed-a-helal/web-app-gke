resource "google_compute_network" "vpc" {

  name                    = "${var.name_prefix}-vpc"
  description             = var.vpc_description
  auto_create_subnetworks = "false" # To disable 
  routing_mode            = "REGIONAL"
}
resource "google_compute_subnetwork" "subnets" {
  for_each      = var.subnets
  name          = "${var.name_prefix}-${each.value.name_suffix}"
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_router" "nat-router" {
  name    = "${var.name_prefix}-nat-router"
  region  = values(google_compute_subnetwork.subnets)[0].region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {

  name                               = "${var.name_prefix}-nat"
  router                             = google_compute_router.nat-router.name
  region                             = values(google_compute_subnetwork.subnets)[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = values(google_compute_subnetwork.subnets)[0].id
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }
}


resource "google_compute_firewall" "allow-ssh-ingress-from-iap" {
  name          = "allow-ssh-from-iap"
  network       = google_compute_network.vpc.id
  source_ranges = ["35.235.240.0/20", ]
  target_tags   = ["allow-iap", ]
  direction     = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}