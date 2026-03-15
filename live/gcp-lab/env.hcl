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
}
