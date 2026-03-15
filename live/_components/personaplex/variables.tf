variable "project_id" { type = string }
variable "region" { type = string }
variable "zone" { type = string }
variable "environment" { type = string }

variable "machine_type" {
  type    = string
  default = "g2-standard-4"
}

variable "gpu_type" {
  type    = string
  default = "nvidia-l4"
}

variable "disk_size_gb" {
  type    = number
  default = 100
}

variable "network" {
  type    = string
  default = "default"
}

variable "ssh_user" { type = string }
variable "ssh_pub_key" { type = string }

variable "hf_token" {
  type        = string
  sensitive   = true
  description = "HuggingFace token to pull PersonaPlex weights"
}
