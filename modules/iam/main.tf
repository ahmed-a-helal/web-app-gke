resource "google_service_account" "service_account" {
  count        = length(var.service_account)
  account_id   = var.service_account[count.index].id
  display_name = "${var.name_prefix}-${var.service_account[count.index].name}"
}
resource "google_project_iam_custom_role" "artifact_access" {
  role_id     = "artifact_repo_fetch_access"
  title       = "${var.name_prefix} artifact repo fetch access"
  description = "this role is designed to fetch images from artifact repo"
  permissions = var.permissions
  project     = var.project
}
data "google_iam_policy" "artifact_access_binding" {
  binding {
    role    = google_project_iam_custom_role.artifact_access.id
    members = [google_service_account.service_account[1].member, ]
  }
}
