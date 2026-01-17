#!/bin/bash

set -e

IMAGE="node2.bdcl:5000/kblam:latest"
MODEL_NAME="/root/hugging_cache/Phi-3-mini-4k-instruct"
DATASET_NAME=${DATASET_NAME:-enron}
TRAIN_DATASET=${TRAIN_DATASET:-train_enr_fixed}
KB_SIZE=${KB_SIZE:-10}
OUT_FOLDER=${OUT_FOLDER:-some_run}
KB_ENCODER=${KB_ENCODER:-stage1_lr_0.0001KBTokenLayerFreq3UseOutlier1UseDataAugKeyFromkey_all-MiniLM-L6-v2_enron_llama3_step_300_encoder/encoder.pt}
KB_MODEL=${KB_MODEL:-stage1_lr_0.0001KBTokenLayerFreq3UseOutlier1UseDataAugKeyFromkey_all-MiniLM-L6-v2_enron_llama3_step_300}

docker pull ${IMAGE}

docker run -it --rm \
	--entrypoint=pdm \
	--workdir=/app \
	-v /data/storage/tmp/kblam-out/${OUT_FOLDER}/${KB_ENCODER}/encoder.pt:/encoder \
	-v /data/storage/tmp/kblam-out/${OUT_FOLDER}/${KB_MODEL}:/model \
	-v /data/storage/tmp/kblam-out/${OUT_FOLDER}:/save_dir \
	-v /var/essdata/DN_1/storage/home/ttn/datasets/kblam/${TRAIN_DATASET}_all-MiniLM-L6-v2_embd_key.npy:/key.npy \
	-v /var/essdata/DN_1/storage/home/ttn/datasets/kblam/${TRAIN_DATASET}_all-MiniLM-L6-v2_embd_value.npy:/value.npy \
	-v /var/essdata/DN_1/storage/home/ttn/datasets/kblam/:/datasets \
	-v /var/essdata/DN_1/storage/home/ttn/models/Phi-3-mini-4k-instruct:${MODEL_NAME} \
	-v /var/essdata/DN_1/storage/home/ttn/models/all-MiniLM-L6-v2:/root/hugging_cache/all-MiniLM-L6-v2 \
	-e CUDA_VISIBLE_DEVICES=5 \
	-e WANDB_MODE=offline \
	${IMAGE} \
	run ./experiments/eval.py generation \
	--dataset_dir=/datasets \
	--encoder_dir=/encoder \
	--encoder_spec=all-MiniLM-L6-v2 \
	--kb_size=${KB_SIZE} \
	--llm_base_dir="${MODEL_NAME}" \
	--llm_type=phi3 \
	--model_dir=/model \
	--test_dataset="${DATASET_NAME}.json" \
	--precomputed_embed_keys_path=/key.npy \
	--precomputed_embed_values_path=/value.npy \
	--train_dataset="${TRAIN_DATASET}.json" \
	--save_dir=/save_dir \
	--eval_mode="kb" \
	--seed=42


