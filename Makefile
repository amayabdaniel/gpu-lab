.PHONY: personaplex-up personaplex-down model-bench-up model-bench-down aerial-up aerial-down nuke validate

# --- PersonaPlex ---
personaplex-up:
	cd live/gcp-lab/personaplex && terragrunt apply

personaplex-down:
	cd live/gcp-lab/personaplex && terragrunt destroy

personaplex-ssh:
	cd live/gcp-lab/personaplex && terragrunt output -raw ssh_command | sh

# --- Model Bench ---
model-bench-up:
	cd live/gcp-lab/model-bench && terragrunt apply

model-bench-down:
	cd live/gcp-lab/model-bench && terragrunt destroy

model-bench-ssh:
	cd live/gcp-lab/model-bench && terragrunt output -raw ssh_command | sh

# --- Aerial Lab ---
aerial-up:
	cd live/gcp-lab/aerial-lab && terragrunt apply

aerial-down:
	cd live/gcp-lab/aerial-lab && terragrunt destroy

aerial-ssh:
	cd live/gcp-lab/aerial-lab && terragrunt output -raw ssh_command | sh

# --- All ---
nuke:
	cd live/gcp-lab && terragrunt run-all destroy --terragrunt-non-interactive

validate:
	cd live/gcp-lab && terragrunt run-all validate --terragrunt-non-interactive

clean:
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".terragrunt-cache" -exec rm -rf {} + 2>/dev/null || true
	find . -name ".terraform.lock.hcl" -delete 2>/dev/null || true
