#!/bin/bash

# Создание символических ссылок на RunPod Storage
if [ -d "/runpod-volume/models" ]; then
    echo "Подключение моделей из RunPod Storage..."
    ln -sf /runpod-volume/models/checkpoints/* /app/ComfyUI/models/checkpoints/ 2>/dev/null || true
    ln -sf /runpod-volume/models/loras/* /app/ComfyUI/models/loras/ 2>/dev/null || true
    ln -sf /runpod-volume/models/vae/* /app/ComfyUI/models/vae/ 2>/dev/null || true
    ln -sf /runpod-volume/models/controlnet/* /app/ComfyUI/models/controlnet/ 2>/dev/null || true
fi

# Подключение кастомных нод
if [ -d "/runpod-volume/custom_nodes" ]; then
    echo "Подключение кастомных нод из RunPod Storage..."
    ln -sf /runpod-volume/custom_nodes/* /app/ComfyUI/custom_nodes/ 2>/dev/null || true
fi

# Запуск ComfyUI в headless режиме
echo "Запуск ComfyUI..."
cd /app/ComfyUI
python3 main.py --listen 0.0.0.0 --port 8188 --cpu --disable-auto-launch
