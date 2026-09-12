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
- SSH access is restricted to the CIDRs you supply — `allowed_ssh_cidrs` is a
  REQUIRED input with no default, and `terraform validate` rejects `0.0.0.0/0`
- Instances are tagged for easy identification and cleanup
- `make nuke` destroys all resources — no orphaned instances

## Network Security

- There is no world-open default. `allowed_ssh_cidrs` and `allowed_app_cidrs` have
  NO defaults and must be supplied in each component's terragrunt inputs; a plan
  without them fails, and a plan supplying `0.0.0.0/0` fails validation.
- This used to be guidance rather than enforcement: the defaults were
  `["0.0.0.0/0"]`, none of the three terragrunt configs overrode them, and the
  app ports include unauthenticated Ollama (8081/11434) and vLLM (8080). Every
  apply opened those to the internet on a billed GPU host. Enforced in code
  2026-09-12.
- Container tags are pinned (`vllm-openai:v0.6.4.post1`, `open-webui:v0.5.20`).
  Floating tags (`:latest`, `:main`) silently change what runs on reboot.
- Consider using IAP (Identity-Aware Proxy) instead of direct SSH for production setups

## Cost Protection

- Instances are NOT preemptible by default (to avoid data loss during testing)
- Always run `make nuke` when done testing
- Set GCP budget alerts to avoid surprise bills
- Label all resources with `managed-by=terragrunt` for easy audit
