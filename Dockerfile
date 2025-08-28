FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Установка системных пакетов
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl ffmpeg libgl1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Ставим PyTorch с CUDA 12.1 (подходит для RTX 40xx/50xx в RunPod)
RUN pip install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cu121 \
    torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2

# Оптимизации для ComfyUI
RUN pip install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cu121 \
    xformers==0.0.23.post1

# Клонируем ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI /app/ComfyUI

# Устанавливаем зависимости ComfyUI
RUN pip install --no-cache-dir -r /app/ComfyUI/requirements.txt

# Папки под модели
RUN mkdir -p /app/ComfyUI/models/checkpoints /app/ComfyUI/models/loras /app/ComfyUI/models/vae

# Открываем порт
EXPOSE 8188

# Запуск ComfyUI
ENTRYPOINT ["python", "/app/ComfyUI/main.py", "--listen", "0.0.0.0", "--port", "8188", "--enable-cors-header", "*"]
