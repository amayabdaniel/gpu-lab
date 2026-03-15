variable "name_prefix" {
  type    = string
  default = "gpu-lab"
}

variable "network" {
  type    = string
  default = "default"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDRs allowed to SSH. Restrict to your IP in production."
}

variable "allowed_app_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "app_ports" {
  type        = list(string)
  default     = ["8998", "8080", "8081", "3000", "9090", "6443"]
  description = "PersonaPlex (8998), vLLM (8080), Ollama (8081), Grafana (3000), Prometheus (9090), k3s API (6443)"
}
