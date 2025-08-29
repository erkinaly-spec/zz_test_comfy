FROM nvidia/cuda:11.8-devel-ubuntu22.04

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    wget \
    curl \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Создание рабочей директории
WORKDIR /app

# Клонирование ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# Установка Python зависимостей
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
RUN pip3 install -r ComfyUI/requirements.txt

# Копирование кастомных файлов
COPY handler.py /app/handler.py
COPY startup.sh /app/startup.sh
RUN chmod +x /app/startup.sh

# Создание директорий для моделей и кастомных нод
RUN mkdir -p /app/ComfyUI/models/checkpoints \
    /app/ComfyUI/models/loras \
    /app/ComfyUI/custom_nodes

# Установка переменных окружения
ENV PYTHONPATH=/app/ComfyUI
ENV COMFYUI_PORT=8188

EXPOSE 8188

CMD ["/app/startup.sh"]
