# External IP
resource "google_compute_global_address" "lb_ip" {
  name         = "${var.service_name}-lb-ip"
  description  = "Static IP for load balancer"
}

# Backend Service
resource "google_compute_backend_service" "backend" {
  name                  = "${var.service_name}-backend"
  protocol              = "HTTP"
  timeout_sec           = 30
  enable_cdn            = false
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_region_network_endpoint_group.neg.id
  }

}

# Network Endpoint Group for Cloud Run
resource "google_compute_region_network_endpoint_group" "neg" {
  name                  = "${var.service_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.cloud_run_service_name
  }
}

# Health Check
resource "google_compute_health_check" "health_check" {
  name               = "${var.service_name}-health-check"
  check_interval_sec = 30
  timeout_sec        = 5

  http_health_check {
    port         = 8080
    request_path = "/health"
  }
}

# URL Map
resource "google_compute_url_map" "url_map" {
  name            = "${var.service_name}-url-map"
  default_service = google_compute_backend_service.backend.id
}

# HTTPS Proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "${var.service_name}-https-proxy"
  url_map          = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.id]
}

# SSL Certificate
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name = "${var.service_name}-ssl-cert"

  managed {
    domains = [var.domain_name]
  }
}

# Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "${var.service_name}-forwarding-rule"
  target     = google_compute_target_https_proxy.https_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.lb_ip.address
}

# HTTP to HTTPS Redirect
resource "google_compute_url_map" "http_redirect" {
  name = "${var.service_name}-http-redirect"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
    https_redirect         = true
  }
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "${var.service_name}-http-proxy"
  url_map = google_compute_url_map.http_redirect.id
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "${var.service_name}-http-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.lb_ip.address
}
