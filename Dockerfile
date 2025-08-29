FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

# Системные пакеты
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 python3-pip python3-venv \
      git wget curl ffmpeg libgl1 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# PyTorch (CUDA 12.1) + xFormers
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir \
      torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 \
      --extra-index-url https://download.pytorch.org/whl/cu121 && \
    pip3 install --no-cache-dir xformers==0.0.23.post1

# Клонируем ComfyUI (shallow)
RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI /app/ComfyUI

# Зависимости ComfyUI
RUN pip3 install --no-cache-dir -r /app/ComfyUI/requirements.txt

# Папки под модели (стандартная структура внутри контейнера)
RUN mkdir -p /app/ComfyUI/models/checkpoints \
             /app/ComfyUI/models/loras \
             /app/ComfyUI/models/vae \
             /app/ComfyUI/models/clip \
             /app/ComfyUI/models/embeddings \
             /app/ComfyUI/models/controlnet \
             /app/ComfyUI/models/unet

# Порт UI
EXPOSE 8188

# Запуск ComfyUI
ENTRYPOINT ["python3", "/app/ComfyUI/main.py", "--listen", "0.0.0.0", "--port", "8188", "--enable-cors-header", "*"]
