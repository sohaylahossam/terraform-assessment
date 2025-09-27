# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
  description             = "VPC network for ${var.project_name}"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  description   = "Subnet for ${var.project_name}"
}

# Firewall Rules
resource "google_compute_firewall" "allow_health_check" {
  name    = "${var.project_name}-allow-health-check"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] # Google health check ranges
  target_tags   = ["http-server"]
  description   = "Allow health check traffic"
}

resource "google_compute_firewall" "allow_lb_to_instances" {
  name    = "${var.project_name}-allow-lb"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
  description   = "Allow HTTP traffic from load balancer"
}

locals {
  connector_name = "${substr(lower(replace(var.project_name, "_", "-")), 0, 15)}-connector"
}

# VPC Connector for Cloud Run
resource "google_vpc_access_connector" "connector" {
  name          = local.connector_name
  ip_cidr_range = var.connector_cidr
  network       = google_compute_network.vpc.name
  region        = var.region
}
