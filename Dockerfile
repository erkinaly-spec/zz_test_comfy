# ... верх оставляем как есть (python:3.11-slim, pip torch, COPY requirements.txt, RUN pip install -r requirements.txt)

# Клонируем ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI /app/ComfyUI

# Ставим зависимости ComfyUI
RUN pip install --no-cache-dir -r /app/ComfyUI/requirements.txt

# (Опционально) каталоги под модели
RUN mkdir -p /app/ComfyUI/models/checkpoints /app/ComfyUI/models/loras /app/ComfyUI/models/vae

# Открываем порт сервера ComfyUI
EXPOSE 8188

# ЗАПУСК: теперь не handler, а сам ComfyUI как HTTP-сервис
CMD ["python", "/app/ComfyUI/main.py", "--listen", "0.0.0.0", "--port", "8188"]
