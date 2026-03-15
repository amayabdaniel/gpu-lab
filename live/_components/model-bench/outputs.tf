output "instance_ip" {
  value = module.instance.external_ip
}

output "ssh_command" {
  value = "ssh ${var.ssh_user}@${module.instance.external_ip}"
}

output "vllm_api" {
  value = "http://${module.instance.external_ip}:8080/v1"
}

output "ollama_api" {
  value = "http://${module.instance.external_ip}:11434"
}
