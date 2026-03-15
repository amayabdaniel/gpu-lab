variable "project_id" { type = string }
variable "region" { type = string }
variable "zone" { type = string }
variable "environment" { type = string }

variable "machine_type" {
  type    = string
  default = "g2-standard-8"
}

variable "gpu_type" {
  type    = string
  default = "nvidia-l4"
}

variable "disk_size_gb" {
  type    = number
  default = 200
}

variable "network" {
  type    = string
  default = "default"
}

variable "ssh_user" { type = string }
variable "ssh_pub_key" { type = string }
