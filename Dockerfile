# Базовый образ с CUDA 12.1 (для PyTorch + GPU)
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    COMFY_PORT=8188

# Установка базовых пакетов
RUN apt-get update && apt-get install -y \
    git python3 python3-pip wget curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# PyTorch с поддержкой CUDA 12.1
RUN pip3 install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cu121 \
    torch==2.1.2+cu121 torchvision==0.16.2+cu121

# Устанавливаем зависимости
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Клонируем ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI /app/ComfyUI

# Создаём папки для моделей
RUN mkdir -p /app/ComfyUI/models/checkpoints /app/ComfyUI/models/loras /app/ComfyUI/models/vae

# Копируем код воркера
COPY handler.py .

# Запускаем воркер (он поднимет ComfyUI headless)
CMD ["python3", "handler.py"]
