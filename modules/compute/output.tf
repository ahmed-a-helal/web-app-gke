output "instance_zone" {
  value = google_compute_instance.gks_control.zone
}
output "nodename" {
  value = google_compute_instance.gks_control.name
}
output "container_name" {
  value = google_container_cluster.primary.name

}
