# Instant-BigGAN-CLIP for NVIDIA Jetson Orin Nano

This is a modified version of Instant-BigGAN-CLIP specifically designed to run on NVIDIA Jetson Orin Nano devices using Docker.

## Prerequisites

### 1. NVIDIA Jetson Orin Nano Setup
- Flash your Jetson Orin Nano with the latest JetPack (recommended: JetPack 5.1+)
- Ensure CUDA and cuDNN are properly installed
- Install Docker and Docker Compose

### 2. Install Docker on Jetson
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin
```

### 3. Install NVIDIA Container Toolkit
```bash
# Add NVIDIA package repositories
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install nvidia-docker2
sudo apt-get update && sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

## Deployment Options

### Option 1: Using Docker Compose (Recommended)

1. **Clone and navigate to the project directory:**
```bash
git clone <your-repo-url>
cd instant-biggan-clip
```

2. **Create workspace directory:**
```bash
mkdir -p workspace
```

3. **Build and run with Docker Compose:**
```bash
# Build and start the container
docker-compose -f docker-compose.jetson.yml up --build

# Or run in detached mode
docker-compose -f docker-compose.jetson.yml up --build -d
```

4. **Access Jupyter Lab:**
   - Open your browser and go to: `http://<jetson-ip>:8080`
   - No password required (configured for development)

### Option 2: Using Docker directly

1. **Build the image:**
```bash
docker build -f Dockerfile.jetson -t instant-biggan-clip:jetson .
```

2. **Run the container:**
```bash
docker run --gpus all \
  --name instant-biggan-clip-jetson \
  -p 8080:8080 \
  -v $(pwd)/workspace:/home/jovyan/work \
  -v /dev/shm:/dev/shm \
  --user 1000:1000 \
  --restart unless-stopped \
  instant-biggan-clip:jetson
```

## Key Differences for Jetson

### Architecture Changes
- **Base Image**: Uses `nvcr.io/nvidia/l4t-pytorch` (ARM64) instead of x86_64
- **CUDA**: Compatible with JetPack CUDA version (11.4)
- **PyTorch**: ARM64-compatible PyTorch builds

### Performance Optimizations
- **Shared Memory**: Mounted `/dev/shm` for better performance
- **GPU Access**: Proper NVIDIA GPU passthrough
- **User Permissions**: Configured for proper file access

### Resource Considerations
- **Memory**: Jetson Orin Nano has 8GB RAM - monitor usage
- **Storage**: Ensure sufficient space for conda environments
- **GPU**: Optimized for Jetson's integrated GPU

## Usage

1. **Access Jupyter Lab** at `http://<jetson-ip>:8080`
2. **Create a new notebook** and select the "Python (torch-gpu-clip)" kernel
3. **Test GPU availability:**
```python
import torch
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA device count: {torch.cuda.device_count()}")
print(f"Current device: {torch.cuda.current_device()}")
print(f"Device name: {torch.cuda.get_device_name()}")
```

## Troubleshooting

### Common Issues

1. **CUDA not detected:**
   - Ensure NVIDIA Container Toolkit is installed
   - Check that `--gpus all` flag is used
   - Verify JetPack installation

2. **Out of memory errors:**
   - Reduce batch sizes in your models
   - Monitor memory usage with `nvidia-smi`
   - Consider using model quantization

3. **Slow performance:**
   - Ensure you're using the GPU-enabled PyTorch
   - Check that models are moved to GPU: `model.cuda()`
   - Monitor GPU utilization

### Performance Tips

1. **Enable GPU memory growth:**
```python
import torch
torch.cuda.empty_cache()
```

2. **Use mixed precision training:**
```python
from torch.cuda.amp import autocast, GradScaler
```

3. **Monitor resources:**
```bash
# Check GPU usage
nvidia-smi

# Check container stats
docker stats instant-biggan-clip-jetson
```

## Stopping the Application

```bash
# Using Docker Compose
docker-compose -f docker-compose.jetson.yml down

# Using Docker directly
docker stop instant-biggan-clip-jetson
docker rm instant-biggan-clip-jetson
```

## File Structure

```
instant-biggan-clip/
├── Dockerfile.jetson          # Jetson-specific Dockerfile
├── environment-jetson.yml     # ARM64/CUDA environment
├── docker-compose.jetson.yml  # Docker Compose configuration
├── README-jetson.md          # This file
└── workspace/                # Persistent storage directory
```

## Notes

- The container runs as user `jovyan` (UID 1000) for proper file permissions
- Workspace directory is mounted for persistent storage
- GPU access is configured for optimal performance
- No authentication is configured (development setup)
