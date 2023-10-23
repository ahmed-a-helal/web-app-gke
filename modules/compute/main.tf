locals {
  gke_cluster = {
    name                   = "${var.name_prefix}-cluster"
    node_pool_name         = "${var.name_prefix}-pool-1"
    machine_type           = "n2-standard-2"
    service_account_email  = var.gke_service_account_email
    location               = data.google_compute_subnetwork.gke_subnet.region
    node_count             = 1
    vpc                    = data.google_compute_subnetwork.gke_subnet.network
    subnet                 = data.google_compute_subnetwork.gke_subnet.id
    enable_private_cluster = true
    enable_global_access   = true
    deletion_protection    = false
    master_ipv4_cidr_block = "172.16.32.0/28"
  }
  management_node = {
    name                  = "${var.name_prefix}-managment-node"
    machine_type          = "n2-standard-2"
    subnet                = "${data.google_compute_subnetwork.management_subnet.id}"
    zone                  = "${data.google_compute_subnetwork.management_subnet.region}-b"
    tags                  = var.management_node_tags
    image                 = "debian-cloud/debian-11"
    service_account_email = var.management_node_service_account_email
    startup_script        = <<EOF
    #! /bin/bash
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null 
    sudo chmod a+r /etc/bash_completion.d/kubectl
    sudo apt-get update -y
    sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin docker-clean docker.io docker docker-compose -y    
    gcloud container clusters get-credentials ${local.gke_cluster.name} --region ${data.google_compute_subnetwork.gke_subnet.region} --project ${data.google_compute_subnetwork.gke_subnet.project}
    EOF

    # local_files_transfere = var.trans_files
    # post_transfere_script = var.post_trans_script

  }
}
data "google_compute_subnetwork" "management_subnet" {
  project = split("/", "${var.management_node_subnet}")[1]
  region  = split("/", "${var.management_node_subnet}")[3]
  name    = split("/", "${var.management_node_subnet}")[5]
}
data "google_compute_subnetwork" "gke_subnet" {
  project = split("/", "${var.gke_subnet}")[1]
  region  = split("/", "${var.gke_subnet}")[3]
  name    = split("/", "${var.gke_subnet}")[5]
}
resource "google_compute_instance" "gks_control" {
  name         = local.management_node.name
  machine_type = local.management_node.machine_type
  zone         = local.management_node.zone
  tags         = local.management_node.tags[0]
  metadata_startup_script = local.management_node.startup_script
  depends_on = [ google_container_cluster.primary ]
  boot_disk {
    initialize_params {
      image = local.management_node.image
      size = 50
    }
  }
  network_interface {
    subnetwork = local.management_node.subnet
  }
  service_account {
    email  = local.management_node.service_account_email
    scopes = ["cloud-platform"]
  }
}

resource "google_container_cluster" "primary" {
  name                     = local.gke_cluster.name
  location                 = local.gke_cluster.location
  network                  = local.gke_cluster.vpc
  subnetwork               = local.gke_cluster.subnet
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = local.gke_cluster.deletion_protection

  private_cluster_config {
    enable_private_nodes    = local.gke_cluster.enable_private_cluster
    enable_private_endpoint = local.gke_cluster.enable_private_cluster
    master_ipv4_cidr_block  = local.gke_cluster.master_ipv4_cidr_block
    master_global_access_config {
      enabled = local.gke_cluster.enable_global_access
    }
  }
  addons_config {
    http_load_balancing {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = data.google_compute_subnetwork.management_subnet.ip_cidr_range
    }

  }
  node_config {
    disk_size_gb = 50
  }


}

resource "google_container_node_pool" "pool1" {
  name       = local.gke_cluster.node_pool_name
  cluster    = google_container_cluster.primary.name
  node_count = local.gke_cluster.node_count
  location   = google_container_cluster.primary.location

  node_config {
    preemptible     = false
    machine_type    = local.gke_cluster.machine_type
    service_account = local.gke_cluster.service_account_email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  upgrade_settings {
    max_surge       = 2
    max_unavailable = 0
    strategy        = "SURGE"
  }
}
