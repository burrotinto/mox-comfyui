#!/bin/bash
# Start model downloads in background so ComfyUI starts immediately.
# Models land on the network volume while ComfyUI is already running.
# First job after a cold start may get "model not found" if download isn't done yet.
/download_extra_models.sh &
exec /start.sh
