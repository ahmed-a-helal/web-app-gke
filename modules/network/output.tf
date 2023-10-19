output "subnet" {
  value = {
    id = google_compute_subnetwork.eks-control-subnet.id
  }
}

output "vpc" {
  value = {
    id = google_compute_network.vpc.id
  }
}