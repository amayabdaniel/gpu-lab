output "ssh_firewall_name" {
  value = google_compute_firewall.ssh.name
}

output "app_firewall_name" {
  value = google_compute_firewall.app_ports.name
}
