variable "name" {
  type = string
}

variable "zone" {
  type = string
}

variable "machine_type" {
  type        = string
  description = "GCE machine type. g2-standard-4 = 1x L4 ($0.80/hr), g2-standard-8 = 1x L4 ($1.50/hr)"

  validation {
    condition     = can(regex("^(g2|a2|a3|n1)-", var.machine_type))
    error_message = "Machine type must be a GPU-capable family (g2, a2, a3, or n1)."
  }
}

variable "gpu_type" {
  type    = string
  default = "nvidia-l4"

  validation {
    condition     = contains(["nvidia-l4", "nvidia-tesla-t4", "nvidia-tesla-a100", "nvidia-h100-80gb"], var.gpu_type)
    error_message = "GPU type must be one of: nvidia-l4, nvidia-tesla-t4, nvidia-tesla-a100, nvidia-h100-80gb."
  }
}

variable "gpu_count" {
  type    = number
  default = 1
}

variable "disk_size_gb" {
  type    = number
  default = 200
}

variable "network" {
  type    = string
  default = "default"
}

variable "ssh_user" {
  type = string
}

variable "ssh_pub_key" {
  type = string
}

variable "startup_script" {
  type    = string
  default = ""
}

variable "workload_label" {
  type    = string
  default = "general"
}

variable "extra_tags" {
  type    = list(string)
  default = []
}

variable "extra_labels" {
  type    = map(string)
  default = {}
}
