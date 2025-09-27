# Log Sink
resource "google_logging_project_sink" "app_sink" {
  name        = "${var.service_name}-logs"
  destination = "storage.googleapis.com/${var.log_bucket_name}"
  filter      = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.service_name}\""

  unique_writer_identity = true
}

# Monitoring Dashboard
resource "google_monitoring_dashboard" "dashboard" {
  dashboard_json = jsonencode({
    displayName = "${var.service_name} Dashboard"
    mosaicLayout = {
      columns = 24
      tiles = [
        {
          width  = 6
          height = 4
          widget = {
            title = "Request Count"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"run.googleapis.com/request_count\" resource.type=\"cloud_run_revision\""
                  }
                }
              }]
            }
          }
        }
      ]
    }
  })
}

# Uptime Check
resource "google_monitoring_uptime_check_config" "health_check" {
  display_name = "${var.service_name}-uptime-check"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/health"
    port         = "443"
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = replace(var.service_url, "https://", "")
    }
  }
}

# Alert Policies
resource "google_monitoring_alert_policy" "high_error_rate" {
  display_name = "${var.service_name} High Error Rate"
  combiner     = "OR"

  conditions {
    display_name = "Error rate > 5%"

    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.05
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  alert_strategy {
    auto_close = "1800s"
  }

  notification_channels = var.notification_channels
}
