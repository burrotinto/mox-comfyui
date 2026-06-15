#!/bin/bash
# Downloads extra models to the network volume on first startup.
# Runs before ComfyUI starts — safe to run on every worker cold start.

CKPT_DIR="/runpod-volume/models/checkpoints"
LORA_DIR="/runpod-volume/models/loras"

mkdir -p "$CKPT_DIR" "$LORA_DIR"

# animagine-xl-4.0 — public HuggingFace model
if [ ! -f "$CKPT_DIR/animagine-xl-4.0.safetensors" ]; then
    echo "[mox] Downloading animagine-xl-4.0 (~6.5 GB)..."
    wget -q -O "$CKPT_DIR/animagine-xl-4.0.safetensors" \
        "https://huggingface.co/cagliostrolab/animagine-xl-4.0/resolve/main/animagine-xl-4.0.safetensors"
    echo "[mox] animagine-xl-4.0 done."
else
    echo "[mox] animagine-xl-4.0 already present, skipping."
fi

# NSFW LoRA — URL passed via NSFW_LORA_URL env var (set in RunPod template)
if [ -n "$NSFW_LORA_URL" ] && [ ! -f "$LORA_DIR/NsfwPovAllInOneLoraSdxl.safetensors" ]; then
    echo "[mox] Downloading NSFW LoRA (~1.7 GB)..."
    wget -q -O "$LORA_DIR/NsfwPovAllInOneLoraSdxl.safetensors" "$NSFW_LORA_URL"
    echo "[mox] NSFW LoRA done."
elif [ -f "$LORA_DIR/NsfwPovAllInOneLoraSdxl.safetensors" ]; then
    echo "[mox] NSFW LoRA already present, skipping."
else
    echo "[mox] NSFW_LORA_URL not set, skipping LoRA download."
fi
