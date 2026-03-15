output "external_ip" {
  value       = google_compute_instance.this.network_interface[0].access_config[0].nat_ip
  description = "Public IP of the GPU instance"
}

output "instance_name" {
  value = google_compute_instance.this.name
}

output "self_link" {
  value = google_compute_instance.this.self_link
}
