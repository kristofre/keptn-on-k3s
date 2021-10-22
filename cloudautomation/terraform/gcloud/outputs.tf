# output "acebox_dashboard" {
#   value = (var.custom_domain != "" ? "http://dashboard.${var.custom_domain}" : "http://dashboard.${google_compute_instance.acebox.network_interface[0].access_config[0].nat_ip}.nip.io")
# }

output "exec-plane-stag_ip" {
  value = "connect using ssh -i key ${var.acebox_user}@${google_compute_instance.exec-plane-stag.network_interface[0].access_config[0].nat_ip}"
}

output "exec-plane-prod_ip" {
  value = "connect using ssh -i key ${var.acebox_user}@${google_compute_instance.exec-plane-prod.network_interface[0].access_config[0].nat_ip}"
}