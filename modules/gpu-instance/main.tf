# =============================================================================
# gpu-instance — GCE instance with NVIDIA GPU and AI tooling
# =============================================================================

resource "google_compute_instance" "this" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/ml-images/global/images/family/common-gpu-debian-12-py312"
      size  = var.disk_size_gb
      type  = "pd-ssd"
    }
  }

  guest_accelerator {
    type  = var.gpu_type
    count = var.gpu_count
  }

  scheduling {
    on_host_maintenance = "TERMINATE"
    automatic_restart   = true
  }

  network_interface {
    network = var.network
    access_config {}
  }

  metadata = {
    ssh-keys              = "${var.ssh_user}:${var.ssh_pub_key}"
    install-nvidia-driver = "True"
  }

  metadata_startup_script = var.startup_script

  tags = concat(["gpu-lab", "allow-ssh"], var.extra_tags)

  labels = merge({
    purpose    = "gpu-lab"
    managed-by = "terragrunt"
    workload   = var.workload_label
  }, var.extra_labels)
}
