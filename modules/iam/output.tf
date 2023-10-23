output "service_accounts" {
  value = google_service_account.service_account.* [0]
}