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
  description = <<-EOT
    CIDRs allowed to SSH (port 22). REQUIRED — there is no default.

    This deliberately has no default. The previous default was ["0.0.0.0/0"],
    which opened SSH to the entire internet on every apply, on a GPU instance
    that bills by the hour. SECURITY.md said to restrict it; nothing enforced
    that, and none of the three terragrunt configs overrode it.

    Set it explicitly, e.g. ["203.0.113.4/32"] for your own address.
  EOT

  validation {
    condition     = length(var.allowed_ssh_cidrs) > 0
    error_message = "allowed_ssh_cidrs must be set explicitly — e.g. [\"YOUR.IP.ADDR/32\"]. Opening SSH to 0.0.0.0/0 on a billed GPU host is not a safe default."
  }

  validation {
    condition     = !contains(var.allowed_ssh_cidrs, "0.0.0.0/0")
    error_message = "allowed_ssh_cidrs must not contain 0.0.0.0/0. If you genuinely need world-open SSH, remove this validation deliberately and record why."
  }
}

variable "allowed_app_cidrs" {
  type        = list(string)
  description = <<-EOT
    CIDRs allowed to reach the application ports. REQUIRED — no default.

    app_ports includes 8081 (Ollama) and 8080 (vLLM), neither of which
    authenticates. A world-open default made those free inference endpoints
    for anyone who port-scanned the host.
  EOT

  validation {
    condition     = length(var.allowed_app_cidrs) > 0
    error_message = "allowed_app_cidrs must be set explicitly. The app ports include unauthenticated inference endpoints (Ollama 8081, vLLM 8080)."
  }

  validation {
    condition     = !contains(var.allowed_app_cidrs, "0.0.0.0/0")
    error_message = "allowed_app_cidrs must not contain 0.0.0.0/0 — that exposes unauthenticated inference endpoints to the internet."
  }
}

variable "app_ports" {
  type        = list(string)
  default     = ["8998", "8080", "8081", "3000", "9090", "6443"]
  description = "PersonaPlex (8998), vLLM (8080), Ollama (8081), Grafana (3000), Prometheus (9090), k3s API (6443)"
}
