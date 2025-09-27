variable "service_name" {
  description = "Service name for resource naming"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "cloud_run_service_name" {
  description = "Cloud Run service name"
  type        = string
}

variable "domain_name" {
  description = "Domain name for SSL certificate"
  type        = string
}
