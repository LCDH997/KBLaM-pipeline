# Use CUDA-enabled base image with Python 3.10
FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install Python 3.10 and system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-dev \
    python3-pip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create symlink for python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Install PDM
RUN pip install --no-cache-dir pdm

# Configure PDM to use venv
ENV PDM_USE_VENV=1

# Set working directory
WORKDIR /app

# Copy project files
COPY pyproject.toml ./
COPY README.md ./
COPY LICENSE ./
COPY src/ ./src/
COPY experiments/ ./experiments/
COPY dataset_generation/ ./dataset_generation/
COPY datasets/ ./datasets/

# Install project dependencies using PDM (including experiment group for wandb, etc.)
# Install the project in editable mode so imports work
# Note: --prod cannot be used with --group, so we install with experiment group
RUN pdm install --group experiment

# Set PDM to use the project's virtual environment
ENV PATH="/app/.venv/bin:$PATH"

# Set entrypoint to pdm
ENTRYPOINT ["pdm"]

# Default command (can be overridden)
CMD ["--help"]

