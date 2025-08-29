#!/bin/bash

# Скрипт для тестирования ComfyUI endpoint

# Конфигурация
ENDPOINT_URL="https://your-endpoint.runpod.net"
API_KEY="your-api-key"

# Простой workflow для тестирования
WORKFLOW='{
  "input": {
    "workflow": {
      "4": {
        "inputs": {"ckpt_name": "model.safetensors"},
        "class_type": "CheckpointLoaderSimple"
      },
      "5": {
        "inputs": {"width": 512, "height": 512, "batch_size": 1},
        "class_type": "EmptyLatentImage"
      },
      "6": {
        "inputs": {"text": "beautiful landscape, high quality", "clip": ["4", 1]},
        "class_type": "CLIPTextEncode"
      },
      "7": {
        "inputs": {"text": "blurry, low quality", "clip": ["4", 1]},
        "class_type": "CLIPTextEncode"
      },
      "3": {
        "inputs": {
          "seed": 123456,
          "steps": 20,
          "cfg": 8,
          "sampler_name": "euler",
          "scheduler": "normal",
          "denoise": 1,
          "model": ["4", 0],
          "positive": ["6", 0],
          "negative": ["7", 0],
          "latent_image": ["5", 0]
        },
        "class_type": "KSampler"
      },
      "8": {
        "inputs": {"samples": ["3", 0], "vae": ["4", 2]},
        "class_type": "VAEDecode"
      },
      "9": {
        "inputs": {"filename_prefix": "Test", "images": ["8", 0]},
        "class_type": "SaveImage"
      }
    },
    "timeout": 300
  }
}'

echo "🧪 Тестирование ComfyUI endpoint..."

# Отправка запроса
echo "📤 Отправка workflow..."
RESPONSE=$(curl -s -X POST "$ENDPOINT_URL/run" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d "$WORKFLOW")

echo "📥 Ответ от endpoint:"
echo "$RESPONSE" | jq '.'

# Проверка успешности
if echo "$RESPONSE" | jq -e '.success' > /dev/null; then
    echo "✅ Тест успешен! Workflow выполнен."
    
    # Получение информации об изображении
    FILENAME=$(echo "$RESPONSE" | jq -r '.outputs."9".images[0].filename')
    if [ "$FILENAME" != "null" ]; then
        echo "🖼️  Сгенерированное изображение: $FILENAME"
        echo "📥 URL для скачивания: $ENDPOINT_URL/view/$FILENAME"
    fi
else
    echo "❌ Тест не прошел. Ошибка:"
    echo "$RESPONSE" | jq -r '.error'
fi
