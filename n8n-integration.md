# Интеграция ComfyUI с n8n

## Настройка n8n HTTP узла

### 1. HTTP Request узел для отправки workflow

**Метод:** POST  
**URL:** `https://your-runpod-endpoint.runpod.net/run`  
**Headers:**
```
Content-Type: application/json
Authorization: Bearer YOUR_RUNPOD_API_KEY
```

**Body (JSON):**
```json
{
  "input": {
    "workflow": {
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
      "4": {
        "inputs": {
          "ckpt_name": "model.safetensors"
        },
        "class_type": "CheckpointLoaderSimple"
      },
      "5": {
        "inputs": {
          "width": 512,
          "height": 512,
          "batch_size": 1
        },
        "class_type": "EmptyLatentImage"
      },
      "6": {
        "inputs": {
          "text": "beautiful landscape, high quality",
          "clip": ["4", 1]
        },
        "class_type": "CLIPTextEncode"
      },
      "7": {
        "inputs": {
          "text": "blurry, low quality",
          "clip": ["4", 1]
        },
        "class_type": "CLIPTextEncode"
      },
      "8": {
        "inputs": {
          "samples": ["3", 0],
          "vae": ["4", 2]
        },
        "class_type": "VAEDecode"
      },
      "9": {
        "inputs": {
          "filename_prefix": "ComfyUI",
          "images": ["8", 0]
        },
        "class_type": "SaveImage"
      }
    },
    "timeout": 300
  }
}
```

### 2. Обработка ответа

**Успешный ответ:**
```json
{
  "success": true,
  "prompt_id": "abc123",
  "outputs": {
    "9": {
      "images": [
        {
          "filename": "ComfyUI_00001_.png",
          "subfolder": "",
          "type": "output"
        }
      ]
    }
  }
}
```

**Ошибка:**
```json
{
  "error": "Описание ошибки"
}
```

### 3. Получение изображения

После получения успешного ответа, изображение можно скачать по URL:
```
https://your-runpod-endpoint.runpod.net/view/ComfyUI_00001_.png
```

## Пример workflow в n8n

1. **HTTP Request** - отправка workflow в ComfyUI
2. **IF** - проверка успешности выполнения
3. **HTTP Request** - скачивание сгенерированного изображения
4. **Save Files** - сохранение изображения локально или в облако

## Переменные окружения

Добавьте в n8n следующие переменные:
- `RUNPOD_ENDPOINT` - URL вашего RunPod endpoint
- `RUNPOD_API_KEY` - API ключ RunPod
- `COMFYUI_TIMEOUT` - таймаут выполнения (по умолчанию 300 секунд)
