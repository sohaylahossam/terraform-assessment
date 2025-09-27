output "service_url" {
  description = "Cloud Run service URL"
  value       = module.cloudrun.service_url
}

output "registry_url" {
  description = "Artifact Registry URL"
  value       = module.artifact_registry.repository_url
}

output "bucket_name" {
  description = "Storage bucket name"
  value       = module.storage.bucket_name
}
