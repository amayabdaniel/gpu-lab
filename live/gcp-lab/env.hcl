# =============================================================================
# env.hcl — GCP lab environment configuration
# =============================================================================

locals {
  project_id = "REPLACE_WITH_YOUR_GCP_PROJECT_ID"
  region     = "us-central1"
  zone       = "us-central1-a"

  # SSH access
  ssh_user    = "daniel"
  ssh_pub_key = file("~/.ssh/id_rsa.pub")

  # Network (default VPC)
  network = "default"

  # -----------------------------------------------------------------------
  # Firewall CIDRs (REQUIRED). The firewall module rejects 0.0.0.0/0 and
  # rejects an empty list — see modules/firewall/variables.tf. Prefer
  # env vars (safer: nothing committed) but a placeholder list works
  # too. root.hcl passes these into every component's inputs.
  #
  # Env vars (comma-separated CIDRs):
  #   GPU_LAB_ALLOWED_SSH_CIDRS  — CIDRs allowed to SSH (port 22)
  #   GPU_LAB_ALLOWED_APP_CIDRS  — CIDRs allowed to reach the app ports
  #                                (which include unauthenticated
  #                                 inference endpoints — Ollama 8081,
  #                                 vLLM 8080)
  #
  # Fallback if the env var is unset: empty list → module validation
  # fails at plan time with a clear message. That is the intended
  # behaviour — an unwired security control MUST fail loud, never
  # silently open.
  allowed_ssh_cidrs = compact(split(",", get_env("GPU_LAB_ALLOWED_SSH_CIDRS", "")))
  allowed_app_cidrs = compact(split(",", get_env("GPU_LAB_ALLOWED_APP_CIDRS", "")))
}
