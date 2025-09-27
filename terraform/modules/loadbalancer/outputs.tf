output "load_balancer_ip" {
  value = google_compute_global_address.lb_ip.address
}

output "load_balancer_url" {
  value = "https://${var.domain_name}"
}
