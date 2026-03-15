# =============================================================================
# model-bench — Multi-model inference benchmark lab
#
# Deploys a GPU instance with vLLM, Ollama, and NVIDIA NIM pre-installed.
# Used to benchmark open-source models (Llama, Qwen, DeepSeek) and compare
# inference engines on the same hardware.
# =============================================================================

module "instance" {
  source = "../../../modules/gpu-instance"

  name           = "model-bench-${var.environment}"
  zone           = var.zone
  machine_type   = var.machine_type
  gpu_type       = var.gpu_type
  gpu_count      = 1
  disk_size_gb   = var.disk_size_gb
  network        = var.network
  ssh_user       = var.ssh_user
  ssh_pub_key    = var.ssh_pub_key
  workload_label = "model-bench"
  startup_script = file("${path.module}/startup.sh")
}

module "firewall" {
  source = "../../../modules/firewall"

  name_prefix = "model-bench-${var.environment}"
  network     = var.network
  app_ports   = ["8080", "8081", "11434", "3000"]
}
