terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "networking" {
  source = "../../modules/networking"

  project_name = var.app_name
  region       = var.region
}

module "artifact_registry" {
  source = "../../modules/registry"

  project_id    = var.project_id
  region        = var.region
  repository_id = "${var.app_name}-repo"
  environment   = var.environment
}

module "storage" {
  source = "../../modules/storage"

  bucket_name = "${var.project_id}-${var.environment}-artifacts"
  location    = var.region
  environment = var.environment
}

module "cloudrun" {
  source = "../../modules/cloudrun"

  project_id         = var.project_id
  region             = var.region
  service_name       = "${var.app_name}-${var.environment}"
  image_url          = var.image_url
  environment        = var.environment
  min_instances      = 0
  max_instances      = 5
  vpc_connector_name = module.networking.vpc_connector_id
}

module "loadbalancer" {
  source = "../../modules/loadbalancer"

  service_name            = "${var.app_name}-${var.environment}"
  region                  = var.region
  cloud_run_service_name  = module.cloudrun.service_name
  domain_name            = var.domain_name
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_id          = var.project_id
  service_name        = module.cloudrun.service_name
  service_url         = module.loadbalancer.load_balancer_url
  log_bucket_name     = module.storage.bucket_name
  notification_channels = var.notification_channels
}
