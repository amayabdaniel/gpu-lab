output "instance_ip" {
  value = module.instance.external_ip
}

output "ssh_command" {
  value = "ssh ${var.ssh_user}@${module.instance.external_ip}"
}

output "web_ui" {
  value = "https://${module.instance.external_ip}:8998"
}
