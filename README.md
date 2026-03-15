# gpu-lab

Terraform + Terragrunt GPU lab for AI inference testing. Spin up, test, tear down.

## Structure

```
modules/                        # Reusable Terraform modules
├── gpu-instance/               # GCE instance with NVIDIA GPU
└── firewall/                   # Network rules for lab access

live/
├── root.hcl                    # Shared backend + provider config
├── _components/                # Workload compositions
│   ├── personaplex/            # NVIDIA PersonaPlex voice AI
│   └── model-bench/            # Multi-model inference benchmark (vLLM, Ollama)
└── gcp-lab/                    # GCP environment
    ├── env.hcl                 # Project ID, region, SSH config
    ├── personaplex/            # terragrunt.hcl → _components/personaplex
    ├── model-bench/            # terragrunt.hcl → _components/model-bench
    └── aerial-lab/             # terragrunt.hcl → _components/model-bench (Aerial testing)
```

## Usage

```bash
# 1. Set your GCP project ID in live/gcp-lab/env.hcl
# 2. Set HuggingFace token for PersonaPlex
export HF_TOKEN=your_token_here

# PersonaPlex voice AI lab (~$0.80/hr)
make personaplex-up        # spin up
make personaplex-ssh       # connect
make personaplex-down      # tear down

# Model benchmark lab (~$1.50/hr)
make model-bench-up        # spin up (vLLM + Ollama + Open WebUI)
make model-bench-ssh       # connect
make model-bench-down      # tear down

# Destroy everything
make nuke
```

## Prerequisites

- GCP account with $300 free credits
- Terraform >= 1.5
- Terragrunt
- SSH key pair at ~/.ssh/id_rsa.pub
- `gcloud auth application-default login`
