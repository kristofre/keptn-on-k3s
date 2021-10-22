## acebox requires public IP address
resource "google_compute_address" "exec-plane-prod" {
  name = "${var.name_prefix}-prod-ipv4-addr-${random_id.uuid.hex}"
}

resource "google_compute_address" "exec-plane-stag" {
  name = "${var.name_prefix}-stag-ipv4-addr-${random_id.uuid.hex}"
}

## Allow access to acebox via HTTPS
resource "google_compute_firewall" "cloudautomation-http" {
  name    = "${var.name_prefix}-allow-http-${random_id.uuid.hex}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = ["${var.name_prefix}-prod-${random_id.uuid.hex}", "${var.name_prefix}-stag-${random_id.uuid.hex}"]
}

## Create staging host
resource "google_compute_instance" "exec-plane-stag" {
  name         = "${var.name_prefix}-stag-${random_id.uuid.hex}"
  machine_type = var.acebox_size
  zone         = var.gcloud_zone

  boot_disk {
    initialize_params {
      image = var.acebox_os
      size  = "40"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.exec-plane-stag.address
    }
  }

  metadata = {
    sshKeys = "${var.acebox_user}:${file(var.ssh_keys["public"])}"
  }

  tags = ["${var.name_prefix}-stag-${random_id.uuid.hex}"]

  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = var.acebox_user
    private_key = file(var.ssh_keys["private"])
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",
      "sudo apt-get install snapd jq curl tree -y",
      "sudo snap install core",
      "sudo snap install yq --channel=v3/stable"
    ]
  }

  provisioner "remote-exec" {
    inline = ["mkdir ~/ace-box/"]
  }

  provisioner "file" {
    source      = "${path.module}/../../../../keptn-on-k3s"
    destination = "~/ace-box/"
  }

}

## Create production host
resource "google_compute_instance" "exec-plane-prod" {
  name         = "${var.name_prefix}-prod-${random_id.uuid.hex}"
  machine_type = var.acebox_size
  zone         = var.gcloud_zone

  boot_disk {
    initialize_params {
      image = var.acebox_os
      size  = "40"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.exec-plane-prod.address
    }
  }

  metadata = {
    sshKeys = "${var.acebox_user}:${file(var.ssh_keys["public"])}"
  }

  tags = ["${var.name_prefix}-prod-${random_id.uuid.hex}"]

  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = var.acebox_user
    private_key = file(var.ssh_keys["private"])
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",
      "sudo apt-get install snapd jq curl tree -y",
      "sudo snap install core",
      "sudo snap install yq --channel=v3/stable"
    ]
  }

  provisioner "remote-exec" {
    inline = ["mkdir ~/ace-box/"]
  }

  provisioner "file" {
    source      = "${path.module}/../../../../keptn-on-k3s"
    destination = "~/ace-box/"
  }
}

resource "null_resource" "provisioner-prod" {

  connection {
    host        = google_compute_instance.exec-plane-prod.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = var.acebox_user
    private_key = file(var.ssh_keys["private"])
  }

  depends_on = [google_dns_record_set.production, google_compute_instance.exec-plane-prod]

  provisioner "remote-exec" {
    inline = [
        "tr -d '\\015' < /home/${var.acebox_user}/ace-box/keptn-on-k3s/install-keptn-on-k3s.sh > /home/${var.acebox_user}/ace-box/keptn-on-k3s/install-keptn-on-k3s_fixed.sh",
        "chmod +x /home/${var.acebox_user}/ace-box/keptn-on-k3s/install-keptn-on-k3s_fixed.sh",
        "DT_TENANT=${var.dt_env} DT_API_TOKEN=${var.dt_api_token} DT_PAAS_TOKEN=${var.dt_paas_token} KEPTN_CONTROL_PLANE_DOMAIN=${var.ca_env} KEPTN_CONTROL_PLANE_API_TOKEN=${var.ca_api_token} OWNER_EMAIL=${var.owner_email} ISTIO=false KEPTN_EXECUTION_PLANE_STAGE_FILTER=production KEPTN_EXECUTION_PLANE_SERVICE_FILTER= KEPTN_EXECUTION_PLANE_PROJECT_FILTER= CUSTOMDOMAIN=production.${var.custom_domain} /home/${var.acebox_user}/ace-box/keptn-on-k3s/install-keptn-on-k3s_fixed.sh --executionplane --provider gcp --with-genericexec --with-monaco --with-gitea --use-custom-domain"
      ]
  }
}

resource "null_resource" "provisioner-stag" {

  connection {
    host        = google_compute_instance.exec-plane-stag.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = var.acebox_user
    private_key = file(var.ssh_keys["private"])
  }

  depends_on = [google_dns_record_set.staging, google_compute_instance.exec-plane-stag]

  provisioner "remote-exec" {
    inline = [
        "tr -d '\\015' < /home/${var.acebox_user}/ace-box/keptn-on-k3s/install-keptn-on-k3s.sh > /home/${var.acebox_user}/ace-box/keptn-on-k3s/install-keptn-on-k3s_fixed.sh",
        "chmod +x /home/${var.acebox_user}/ace-box/keptn-on-k3s/install-keptn-on-k3s_fixed.sh",
        "DT_TENANT=${var.dt_env} DT_API_TOKEN=${var.dt_api_token} DT_PAAS_TOKEN=${var.dt_paas_token} KEPTN_CONTROL_PLANE_DOMAIN=${var.ca_env} KEPTN_CONTROL_PLANE_API_TOKEN=${var.ca_api_token} OWNER_EMAIL=${var.owner_email} ISTIO=false KEPTN_EXECUTION_PLANE_STAGE_FILTER=staging KEPTN_EXECUTION_PLANE_SERVICE_FILTER= KEPTN_EXECUTION_PLANE_PROJECT_FILTER= CUSTOMDOMAIN=staging.${var.custom_domain} /home/${var.acebox_user}/ace-box/keptn-on-k3s/install-keptn-on-k3s_fixed.sh --executionplane --provider gcp --with-genericexec --with-monaco --use-custom-domain"
      ]
  }
}

resource "null_resource" "create-projects" {

  connection {
    host        = google_compute_instance.exec-plane-prod.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = var.acebox_user
    private_key = file(var.ssh_keys["private"])
  }

  depends_on = [null_resource.provisioner-stag, null_resource.provisioner-prod]

  provisioner "remote-exec" {
    inline = [
        "cd /home/${var.acebox_user}/ace-box/keptn-on-k3s/cloudautomation/scripts/",
        "chmod +x install-cloudautomation-workshop.sh",
        "TENANTS_FILE=./cloudautomation/scripts/tenants.ca1.sh KEPTN_CONTROL_PLANE_DOMAIN=${var.ca_env} OWNER_EMAIL=${var.owner_email} KEPTN_EXECUTION_PLANE_INGRESS_DOMAIN=production.${var.custom_domain} KEPTN_PRODUCTION_INGRESS=production.${var.custom_domain} KEPTN_STAGING_INGRESS=staging.${var.custom_domain} ./install-cloudautomation-workshop.sh"
      ]
  }
}

# "/home/${var.acebox_user}/install-keptn-on-k3s_fixed.sh  --ip=${google_compute_instance.acebox.network_interface.0.access_config.0.nat_ip} --user=${var.acebox_user} --custom-domain=${var.custom_domain}"