FROM runpod/worker-comfyui:5.2.0-base

# Install ComfyUI_InstantID custom node + its dependencies
RUN git clone -q https://github.com/cubiq/ComfyUI_InstantID.git /comfyui/custom_nodes/ComfyUI_InstantID && \
    pip install -q insightface==1.0.1 onnxruntime -r /comfyui/custom_nodes/ComfyUI_InstantID/requirements.txt

# Bake insightface/antelopev2 models into image (~330MB) — avoids runtime download failures
RUN mkdir -p /comfyui/models/insightface/models/antelopev2 && \
    cd /comfyui/models/insightface/models/antelopev2 && \
    for f in 1k3d68.onnx 2d106det.onnx genderage.onnx glintr100.onnx scrfd_10g_bnkps.onnx; do \
        wget -q -O $f "https://huggingface.co/MonsterMMORPG/tools/resolve/main/$f"; \
    done

# Register instantid path from network volume (ip-adapter + controlnet stay on volume)
RUN printf '\nmox_extra:\n    base_path: /runpod-volume/\n    instantid: models/instantid/\n' >> /comfyui/extra_model_paths.yaml

# Copy face reference and KPS image so they're always available in workflows
COPY input/ /comfyui/input/

# Model download script — runs on cold start, downloads to network volume if not present
COPY download_extra_models.sh /download_extra_models.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /download_extra_models.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
