#!/bin/bash
set -euo pipefail

exec > /var/log/gpu-lab-startup.log 2>&1
echo "=== GPU Lab startup: PersonaPlex ==="
echo "Started at: $(date)"

# Wait for NVIDIA driver to be ready
echo "Waiting for NVIDIA driver..."
for i in $(seq 1 60); do
  nvidia-smi &>/dev/null && break
  sleep 5
done
nvidia-smi

# Install NVIDIA Container Toolkit
echo "Installing NVIDIA Container Toolkit..."
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
apt-get update && apt-get install -y nvidia-container-toolkit
nvidia-ctk runtime configure --runtime=docker
systemctl restart docker

# Clone and set up PersonaPlex
echo "Cloning PersonaPlex..."
cd /opt
git clone https://github.com/NVIDIA/personaplex.git
cd personaplex

# Set HuggingFace token
export HF_TOKEN="${hf_token}"

# Build container
echo "Building PersonaPlex container..."
docker compose build

# Start PersonaPlex
echo "Starting PersonaPlex..."
HF_TOKEN="${hf_token}" docker compose up -d

echo "=== GPU Lab startup complete ==="
echo "PersonaPlex available at https://$(curl -s ifconfig.me):8998"
echo "Finished at: $(date)"
