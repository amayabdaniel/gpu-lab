# Security Policy

## Reporting Vulnerabilities

Email: daniel.amaya.buitrago@outlook.com

DO NOT open public issues for security vulnerabilities.

## Secrets Management

- HuggingFace tokens should be stored in GCP Secret Manager, not in tfvars files
- Never commit `.tfvars` files with real credentials (gitignored by default)
- Startup scripts retrieve secrets from Secret Manager at boot time
- SSH keys are injected via instance metadata, not baked into images

## Instance Hardening

- GPU instances use Google's ML-optimized images with latest NVIDIA drivers
- Firewall rules scope access to specific ports only
- SSH access should be restricted to your IP (update `allowed_ssh_cidrs` in firewall module)
- Instances are tagged for easy identification and cleanup
- `make nuke` destroys all resources — no orphaned instances

## Network Security

- Default firewall allows SSH from anywhere — restrict `allowed_ssh_cidrs` for production use
- Application ports (8998, 8080, etc.) are open by default — restrict for production
- Consider using IAP (Identity-Aware Proxy) instead of direct SSH for production setups

## Cost Protection

- Instances are NOT preemptible by default (to avoid data loss during testing)
- Always run `make nuke` when done testing
- Set GCP budget alerts to avoid surprise bills
- Label all resources with `managed-by=terragrunt` for easy audit
