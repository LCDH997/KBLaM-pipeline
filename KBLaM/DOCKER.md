# Docker Setup for KBLaM

This guide explains how to build, push, and use the KBLaM Docker image.

## Building the Docker Image

To build the Docker image locally:

```bash
docker build -t kblam:latest .
```

Or with a specific tag:

```bash
docker build -t kblam:v0.0.1 .
```

## Using Docker Registry

### 1. Tag the Image for Your Registry

First, tag your local image with the registry URL:

```bash
docker tag kblam:latest node2.bdcl:5000/kblam:latest
```

Or for a specific version:

```bash
docker tag kblam:latest node2.bdcl:5000/kblam:v0.0.1
```

### 2. Push to Registry

Push the image to your Docker registry:

```bash
docker push node2.bdcl:5000/kblam:latest
```

**Note:** Make sure you're authenticated with the registry if it requires authentication. For private registries, you may need to:

```bash
docker login node2.bdcl:5000
```

### 3. Pull from Registry

On the target machine, pull the image:

```bash
docker pull node2.bdcl:5000/kblam:latest
```

## Running with Docker Compose

### Using Environment Variables

Create a `.env` file (optional) to set environment variables:

```bash
CUDA_VISIBLE_DEVICES=2
SAVE_PERIOD=600
WANDB_MODE=offline
DATASET_NAME=enronqwe 
OUTPUT_DIR=/data/storage/tmp/kblam-out/run_3
DATASETS_DIR=/var/essdata/DN_1/storage/home/ttn/datasets/kblam
MODEL_CACHE_DIR=/var/essdata/DN_1/storage/home/ttn/models
```

Then run:

```bash
docker compose up -d
```

Or run in foreground:

```bash
docker compose up
```

### Overriding Volumes

You can override volume mounts directly in the command:

```bash
DATASETS_DIR=/path/to/datasets \
MODEL_CACHE_DIR=/path/to/models \
OUTPUT_DIR=/path/to/output \
docker compose up
```

### Viewing Logs

```bash
docker compose logs -f kblam
```

### Stopping the Container

```bash
docker compose down
```

## Running with Docker Run (Alternative)

If you prefer using `docker run` directly (as in your original script):

```bash
docker run -it -d --name=kblam \
    --entrypoint=pdm \
    --workdir=/app \
    --gpus device=2 \
    -v /data/storage/tmp/kblam-out/run_3:/output \
    -v /var/essdata/DN_1/storage/home/ttn/datasets/kblam:/datasets \
    -v /var/essdata/DN_1/storage/home/ttn/models/all-MiniLM-L6-v2:/root/hugging_cache/all-MiniLM-L6-v2 \
    -v /var/essdata/DN_1/storage/home/ttn/models/Phi-3-mini-4k-instruct:/root/hugging_cache/Phi-3-mini-4k-instruct \
    -e CUDA_VISIBLE_DEVICES=2 \
    -e SAVE_PERIOD=600 \
    -e WANDB_MODE=offline \
    node2.bdcl:5000/kblam:latest \
    run ./experiments/train.py \
    --dataset_dir=/datasets \
    --train_dataset=enron \
    --N=120000 \
    --B=1 \
    --total_steps=601 \
    --encoder_spec=all-MiniLM-L6-v2 \
    --key_embd_src=key \
    --use_data_aug \
    --use_cached_embd \
    --llm_type=phi3 \
    --hf_model_spec=/root/hugging_cache/Phi-3-mini-4k-instruct \
    --model_save_dir=/output \
    --log_to_file \
    --verbose
```

## Customizing the Training Command

You can override the command in `compose.yaml` or pass it directly:

```bash
docker compose run kblam run ./experiments/train.py --help
```

Or modify the `command` section in `compose.yaml` to match your specific training needs.

## Troubleshooting

### Container Name Already in Use

If you get an error like "The container name '/kblam' is already in use", you have several options:

**Option 1: Remove the existing container**
```bash
# Stop and remove the existing container
docker stop kblam
docker rm kblam
```

**Option 2: Remove the container if it's stopped**
```bash
docker rm kblam
```

**Option 3: Force remove (if container is running)**
```bash
docker rm -f kblam
```

**Option 4: Use a different container name**
Modify your script to use a unique name, for example:
```bash
docker run -it -d --name=kblam-$(date +%s) ...
```

**Option 5: Check container status first**
```bash
# List all containers (including stopped)
docker ps -a | grep kblam

# If you want to reuse a stopped container, start it instead
docker start kblam
```

### GPU Access Issues

If GPU is not accessible, ensure:
1. NVIDIA Docker runtime is installed: `nvidia-docker` or `nvidia-container-toolkit`
2. The `--gpus` flag is used (for `docker run`) or `deploy.resources.reservations.devices` is configured (for compose)

### Permission Issues

If you encounter permission issues with mounted volumes, you may need to adjust file permissions or use `--user` flag:

```bash
docker run --user $(id -u):$(id -g) ...
```

### Registry Authentication

For private registries, ensure you're logged in:

```bash
docker login node2.bdcl:5000
```

Enter your credentials when prompted.

