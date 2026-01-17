#!/bin/bash

set -e

IMAGE="node2.bdcl:5000/kblam:latest"
DATASET_NAME=${DATASET_NAME:-enron}

docker pull ${IMAGE}

docker run -it --rm \
	--entrypoint=pdm \
	--workdir=/app \
	-v /var/essdata/DN_1/storage/home/ttn/datasets/kblam/:/output/datasets \
	-v /var/essdata/DN_1/storage/home/ttn/models/all-MiniLM-L6-v2:/root/hugging_cache/all-MiniLM-L6-v2 \
	-e CUDA_VISIBLE_DEVICES=1 \
	${IMAGE} \
	run ./dataset_generation/generate_kb_embeddings.py \
	--model_name=all-MiniLM-L6-v2 \
	--dataset_name="${DATASET_NAME}" \
	--dataset_path="/output/datasets/${DATASET_NAME}.json" \
	--output_path=/output/datasets



