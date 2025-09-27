variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "image_url" {
  description = "Container image URL"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/stage/prod)"
  type        = string
  default     = "dev"
}

variable "vpc_connector_name" {
  description = "Optional VPC connector name for Cloud Run"
  type        = string
  default     = null
}

variable "min_instances" {
  description = "Minimum number of Cloud Run instances to keep warm"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10
}

