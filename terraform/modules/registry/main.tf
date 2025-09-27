resource "google_artifact_registry_repository" "app_repo" {
  location      = var.region
  repository_id = var.repository_id
  description   = "Docker repository for Terraform Assessment"
  format        = "DOCKER"

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
