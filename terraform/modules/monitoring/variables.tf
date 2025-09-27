variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
}

variable "service_url" {
  description = "URL of the service"
  type        = string
}

variable "log_bucket_name" {
  description = "Name of bucket for logs"
  type        = string
}

variable "notification_channels" {
  description = "List of notification channels for alerts"
  type        = list(string)
  default     = []
}
