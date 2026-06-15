FROM runpod/worker-comfyui:5.2.0-base

# Install ComfyUI_InstantID custom node + its dependencies
RUN git clone -q https://github.com/cubiq/ComfyUI_InstantID.git /comfyui/custom_nodes/ComfyUI_InstantID && \
    pip install -q insightface==1.0.1 onnxruntime -r /comfyui/custom_nodes/ComfyUI_InstantID/requirements.txt

# Extend extra_model_paths.yaml to include instantid + insightface paths from network volume
RUN python3 -c "
import yaml
with open('/comfyui/extra_model_paths.yaml') as f:
    cfg = yaml.safe_load(f)
cfg['comfyui']['instantid'] = 'models/instantid/'
cfg['comfyui']['insightface'] = 'models/insightface/'
with open('/comfyui/extra_model_paths.yaml', 'w') as f:
    yaml.dump(cfg, f, default_flow_style=False)
"

# Copy face reference and KPS image so they're always available in workflows
COPY input/ /comfyui/input/
