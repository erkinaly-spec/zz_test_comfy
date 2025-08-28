# База с Python
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    DEBIAN_FRONTEND=noninteractive

# Базовые пакеты для ComfyUI/torch и работы с изображениями/видео
RUN apt-get update && apt-get install -y --no-install-recommends \
      git wget curl ffmpeg libgl1 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# (если есть свои питон-зависимости)
COPY requirements.txt /app/requirements.txt

# CUDA-сборки PyTorch под 12.1 + ваши зависимости
RUN pip install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cu121 \
      torch==2.1.2+cu121 torchvision==0.16.2+cu121 \
    && pip install --no-cache-dir -r /app/requirements.txt

# Клонируем ComfyUI и ставим его зависимости
RUN git clone https://github.com/comfyanonymous/ComfyUI /app/ComfyUI
RUN pip install --no-cache-dir -r /app/ComfyUI/requirements.txt

# Папки под модели
RUN mkdir -p /app/ComfyUI/models/checkpoints /app/ComfyUI/models/loras /app/ComfyUI/models/vae

# Порт ComfyUI
EXPOSE 8188

# Запуск ComfyUI как сервиса (для Load Balancer)
CMD ["python", "/app/ComfyUI/main.py", "--listen", "0.0.0.0", "--port", "8188"]
