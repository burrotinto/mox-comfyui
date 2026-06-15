FROM runpod/worker-comfyui:5.2.0-base

# Install ComfyUI_InstantID custom node + its dependencies
RUN git clone -q https://github.com/cubiq/ComfyUI_InstantID.git /comfyui/custom_nodes/ComfyUI_InstantID && \
    pip install -q insightface==1.0.1 onnxruntime -r /comfyui/custom_nodes/ComfyUI_InstantID/requirements.txt

# Extend extra_model_paths.yaml to include instantid + insightface paths from network volume
RUN echo "  instantid: models/instantid/" >> /comfyui/extra_model_paths.yaml && \
    echo "  insightface: models/insightface/" >> /comfyui/extra_model_paths.yaml

# Copy face reference and KPS image so they're always available in workflows
COPY input/ /comfyui/input/
