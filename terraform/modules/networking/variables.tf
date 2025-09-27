variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "connector_cidr" {
  description = "CIDR block for VPC connector"
  type        = string
  default     = "10.0.2.0/28"
}
