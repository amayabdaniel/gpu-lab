# =============================================================================
# firewall — GPU lab network rules
# =============================================================================

resource "google_compute_firewall" "ssh" {
  name    = "${var.name_prefix}-allow-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_cidrs
  target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "app_ports" {
  name    = "${var.name_prefix}-allow-app"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = var.app_ports
  }

  source_ranges = var.allowed_app_cidrs
  target_tags   = ["gpu-lab"]
}
