terraform {
  backend "gcs" {
    bucket = "terraform-assess-26565-terraform-state"
    prefix = "terraform/state"
  }
}
