FROM python:3.11-slim

# Ставим зависимости
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Копируем requirements.txt (если у тебя там torch и т.д.)
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Клонируем ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI /app/ComfyUI

# Устанавливаем зависимости ComfyUI
RUN pip install --no-cache-dir -r /app/ComfyUI/requirements.txt

# Создаём каталоги под модели
RUN mkdir -p /app/ComfyUI/models/checkpoints /app/ComfyUI/models/loras /app/ComfyUI/models/vae

# Открываем порт для ComfyUI
EXPOSE 8188

# Явный старт ComfyUI
ENTRYPOINT ["python", "/app/ComfyUI/main.py", "--listen", "0.0.0.0", "--port", "8188"]
