variable "gcloud_project" {
  description = "Google Cloud Project where resources will be created"
}

variable "gcloud_zone" {
  description = "Google Cloud Zone where resources will be created"
}

variable "gcloud_cred_file" {
  description = "Path to GCloud credential file"
}

variable "name_prefix" {
  description = "Prefix to distinguish the instance"
  default = "ace-box-cloud"
}

variable "acebox_size" {
  description = "Size (machine type) of the ace-box instance"
  default     = "n2-standard-8"
}

variable "acebox_user" {
  description = "Initial user when ace-box is created"
  default     = "ace"
}

variable "acebox_os" {
  description = "Ubuntu version to use"
  default     = "ubuntu-minimal-2004-lts"
}

variable "ssh_keys" {
  description = "Paths to public and private SSH keys for ace-box user"
  default = {
    private = "./key"
    public  = "./key.pub"
  }
}

variable "custom_domain" {
  description = "Set to overwrite custom domain"
  default     = ""
}

variable "managed_zone_name" {
  description = "Name of GCP managed zone"
  default     = ""
}

variable "dt_env" {
  description = "URL of Dynatrace Environment (SaaS or Managed)"
}

variable "dt_api_token" {
  description = "Dynatrace API Token"
}

variable "dt_paas_token" {
  description = "Dynatrace PaaS Token"
}

variable "ca_env" {
  description = "URL of Cloud Automation Environment"
}

variable "ca_api_token" {
  description = "Cloud Automation API Token"
}

variable "owner_email" {
  description = "Owner Email"
}