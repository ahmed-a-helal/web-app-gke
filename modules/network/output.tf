output "subnets" {
  value = {
    subnets = google_compute_subnetwork.subnets.* [0]
  }
}

output "vpc" {
  value = {
    id = google_compute_network.vpc.id
  }
}

output "iap-tag" {
  value = google_compute_firewall.allow-ssh-ingress-from-iap.target_tags
}