# =============================================================================
# personaplex — NVIDIA PersonaPlex voice AI lab
#
# Deploys a GPU instance pre-configured to run PersonaPlex full-duplex voice AI.
# Startup installs Docker, NVIDIA Container Toolkit, clones PersonaPlex, and
# starts the server. Instance is ready to test within ~10 min of apply.
# =============================================================================

module "instance" {
  source = "../../../modules/gpu-instance"

  name           = "personaplex-${var.environment}"
  zone           = var.zone
  machine_type   = var.machine_type
  gpu_type       = var.gpu_type
  gpu_count      = 1
  disk_size_gb   = var.disk_size_gb
  network        = var.network
  ssh_user       = var.ssh_user
  ssh_pub_key    = var.ssh_pub_key
  workload_label = "personaplex"
  extra_tags     = ["allow-personaplex"]
  startup_script = templatefile("${path.module}/startup.sh", {
    hf_token = var.hf_token
  })
}

module "firewall" {
  source = "../../../modules/firewall"

  name_prefix = "personaplex-${var.environment}"
  network     = var.network
  app_ports   = ["8998"]
}
