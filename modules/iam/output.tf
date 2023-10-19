output "service_account_no_permission" {
  value = google_service_account.service_account[0].id
}

output "vpc" {
  value = google_service_account.service_account[1].id
}