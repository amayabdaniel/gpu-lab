#!/bin/bash
set -euo pipefail

exec > /var/log/gpu-lab-startup.log 2>&1
echo "=== GPU Lab startup: Model Bench ==="
echo "Started at: $(date)"

# Wait for NVIDIA driver
for i in $(seq 1 60); do nvidia-smi &>/dev/null && break; sleep 5; done
nvidia-smi

# Install NVIDIA Container Toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
apt-get update && apt-get install -y nvidia-container-toolkit
nvidia-ctk runtime configure --runtime=docker
systemctl restart docker

# Install Ollama
echo "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# Pull a default model for quick testing
echo "Pulling Qwen3 8B via Ollama..."
ollama pull qwen3:8b &

# Install vLLM
echo "Starting vLLM container..."
docker run -d \
  --name vllm \
  --gpus all \
  --restart unless-stopped \
  -p 8080:8000 \
  -e VLLM_ALLOW_LONG_MAX_MODEL_LEN=1 \
  vllm/vllm-openai:latest \
  --model Qwen/Qwen3-8B \
  --max-model-len 4096 \
  --gpu-memory-utilization 0.45

# Install Open WebUI for chat interface
echo "Starting Open WebUI..."
docker run -d \
  --name open-webui \
  --restart unless-stopped \
  -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
  --add-host host.docker.internal:host-gateway \
  ghcr.io/open-webui/open-webui:main

echo "=== GPU Lab startup complete ==="
echo "vLLM API: http://$(curl -s ifconfig.me):8080/v1"
echo "Ollama API: http://$(curl -s ifconfig.me):11434"
echo "Open WebUI: http://$(curl -s ifconfig.me):3000"
echo "Finished at: $(date)"
