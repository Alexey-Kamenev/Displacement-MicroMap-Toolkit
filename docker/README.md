# Docker Setup for Displacement-MicroMap-Toolkit

This directory contains scripts and configuration files for building and running the Displacement-MicroMap-Toolkit in a Docker container.

## Prerequisites

- Docker installed on your system
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html) installed for GPU support
- NVIDIA drivers installed on the host system
- X11 forwarding support for GUI applications

## Scripts and Configuration Files

- `build_docker.sh`: Script to build the Docker image
- `run_docker.sh`: Script to run the Docker container
- `nvidia_icd.json`: NVIDIA ICD (Installable Client Driver) configuration for OpenGL support

## Building the Docker Image

To build the Docker image, run:

```bash
./build_docker.sh
```

By default, this will create an image named `physicsnemo-remeshing:latest`. You can customize the image name and tag by setting environment variables:

```bash
IMAGE_NAME="custom-name" IMAGE_TAG="v1.0" ./build_docker.sh
```

## Running the Container

To run the container, execute:

```bash
./run_docker.sh
```

The script will:
1. Check if a container with the name `physicsnemo-remeshing` already exists
2. Create a new container if it doesn't exist, or start the existing one
3. Mount necessary volumes and set up GPU access
4. Launch an interactive bash session inside the container

### Customization

You can customize the container setup by setting these environment variables:

- `IMAGE_NAME`: Docker image name (default: "physicsnemo-remeshing")
- `IMAGE_TAG`: Docker image tag (default: "latest")
- `USER_NAME`: Username inside the container (default: "ubuntu")
- `CONTAINER_NAME`: Name of the container (default: "physicsnemo-remeshing")
- `HOST_DATA_DIR`: Host directory to mount (default: "/data")
- `CONTAINER_DATA_DIR`: Container directory for mounting (default: "/data")

Example:
```bash
USER_NAME="custom-user" HOST_DATA_DIR="/path/to/data" ./run_docker.sh
```

## Container Features

The container is configured with:
- Full GPU support with NVIDIA drivers
- X11 forwarding for GUI applications
- Shared memory access
- Host network access
- System time synchronization
- Memory and stack size limits configured for optimal performance
- Data directory mounting for persistent storage

## Troubleshooting

1. If you encounter GPU-related issues:
   - Ensure NVIDIA drivers are installed on the host
   - Verify NVIDIA Container Toolkit is properly installed
   - Check if the `nvidia-smi` command works on the host

2. For X11 forwarding issues:
   - Make sure X11 forwarding is enabled on your host
   - Check if the DISPLAY environment variable is set correctly

3. For permission issues:
   - Ensure the mounted directories have appropriate permissions
   - Check if the specified user exists in the container
