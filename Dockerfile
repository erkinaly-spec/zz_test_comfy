FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    COMFY_PORT=8188

# базовые пакеты
RUN apt-get update && apt-get install -y \
    git wget curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# PyTorch с CUDA 12.1 (драйверы подмонтирует RunPod)
RUN pip install --no-cache-dir --extra-index-url https://download.pytorch.org/whl/cu121 \
    torch==2.1.2+cu121 torchvision==0.16.2+cu121

# зависимости
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI /app/ComfyUI
RUN mkdir -p /app/ComfyUI/models/checkpoints /app/ComfyUI/models/loras /app/ComfyUI/models/vae

COPY handler.py .

CMD ["python", "handler.py"]
