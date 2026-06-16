#!/bin/bash
# Downloads extra models to the network volume on first startup.
# All downloads are best-effort — failures are logged but don't crash ComfyUI.

CKPT_DIR="/runpod-volume/models/checkpoints"
LORA_DIR="/runpod-volume/models/loras"

mkdir -p "$CKPT_DIR" "$LORA_DIR" || true

if [ -f "$CKPT_DIR/juggernautXL_v8Rundiffusion.safetensors" ]; then
    echo "[mox] Removing retired juggernautXL_v8Rundiffusion.safetensors to free volume space..."
    rm -f "$CKPT_DIR/juggernautXL_v8Rundiffusion.safetensors"
fi

download_model() {
    local dest="$1"
    local url="$2"
    local name="$3"
    if [ -f "$dest" ]; then
        echo "[mox] $name already present, skipping."
        return 0
    fi
    echo "[mox] Downloading $name..."
    if wget -q --timeout=600 --tries=2 -O "${dest}.tmp" "$url" 2>&1; then
        mv "${dest}.tmp" "$dest"
        echo "[mox] $name done."
    else
        rm -f "${dest}.tmp"
        echo "[mox] WARNING: $name download failed — ComfyUI will start without it."
    fi
}

# animagine-xl-4.0 — public HuggingFace model
download_model \
    "$CKPT_DIR/animagine-xl-4.0.safetensors" \
    "https://huggingface.co/cagliostrolab/animagine-xl-4.0/resolve/main/animagine-xl-4.0.safetensors" \
    "animagine-xl-4.0"

# Illustrious-XL v2.0 — public HuggingFace model (newer anime/NSFW alternative to animagine)
download_model \
    "$CKPT_DIR/Illustrious-XL-v2.0.safetensors" \
    "https://huggingface.co/OnomaAIResearch/Illustrious-XL-v2.0/resolve/main/Illustrious-XL-v2.0.safetensors" \
    "Illustrious-XL-v2.0"

# NSFW LoRA — URL from NSFW_LORA_URL env var (set in RunPod template)
if [ -n "$NSFW_LORA_URL" ]; then
    download_model \
        "$LORA_DIR/NsfwPovAllInOneLoraSdxl.safetensors" \
        "$NSFW_LORA_URL" \
        "NSFW LoRA"
else
    echo "[mox] NSFW_LORA_URL not set, skipping LoRA."
fi

echo "[mox] Model setup complete, starting ComfyUI..."
