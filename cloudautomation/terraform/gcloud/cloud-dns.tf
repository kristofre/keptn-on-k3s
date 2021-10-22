resource "google_dns_record_set" "staging" {
  count = var.custom_domain == "" ? 0 : 1

  managed_zone = var.managed_zone_name
  name         = "*.staging.${var.custom_domain}."
  type         = "A"
  rrdatas      = [google_compute_instance.exec-plane-stag.network_interface[0].access_config[0].nat_ip]
  ttl          = 300
}

resource "google_dns_record_set" "production" {
  count = var.custom_domain == "" ? 0 : 1

  managed_zone = var.managed_zone_name
  name         = "*.production.${var.custom_domain}."
  type         = "A"
  rrdatas      = [google_compute_instance.exec-plane-prod.network_interface[0].access_config[0].nat_ip]
  ttl          = 300
}