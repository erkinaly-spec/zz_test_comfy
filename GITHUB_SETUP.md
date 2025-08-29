# Настройка GitHub интеграции для ComfyUI

## 🚀 Быстрый старт

1. **Создайте репозиторий на GitHub**
2. **Настройте GitHub Secrets**
3. **Настройте RunPod Storage**
4. **Запустите первый деплой**

## 📋 Пошаговая настройка

### 1. Создание GitHub репозитория

```bash
# Клонируйте этот проект
git clone https://github.com/YOUR_USERNAME/comfyui-runpod.git
cd comfyui-runpod

# Создайте новый репозиторий на GitHub
# Затем инициализируйте git и отправьте код
git init
git add .
git commit -m "Initial commit: ComfyUI RunPod setup"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/comfyui-runpod.git
git push -u origin main
```

### 2. Настройка GitHub Secrets

Перейдите в ваш репозиторий → Settings → Secrets and variables → Actions

Добавьте следующие secrets:

#### `RUNPOD_API_KEY`
- Получите API ключ в [RunPod Console](https://www.runpod.io/console/user/settings)
- Перейдите в Settings → API Keys
- Создайте новый API ключ

#### `RUNPOD_ENDPOINT` (опционально)
- URL вашего RunPod endpoint после создания
- Формат: `https://your-endpoint-id.proxy.runpod.net`

### 3. Настройка RunPod Storage

1. Войдите в [RunPod Console](https://www.runpod.io/console)
2. Перейдите в Storage
3. Создайте новый Storage или используйте существующий
4. Загрузите ваши модели в следующую структуру:

```
/runpod-volume/
├── models/
│   ├── checkpoints/     # .safetensors файлы
│   ├── loras/          # LoRA модели
│   ├── vae/            # VAE модели
│   └── controlnet/     # ControlNet модели
└── custom_nodes/       # Кастомные ноды
```

### 4. Обновление конфигурации

Отредактируйте файлы с вашими данными:

#### `runpod-template.json`
```json
{
  "dockerImageName": "ghcr.io/YOUR_USERNAME/comfyui-runpod:latest",
  "volumeMounts": [
    {
      "volumeId": "YOUR_ACTUAL_STORAGE_ID",
      "volumeMountPath": "/runpod-volume"
    }
  ]
}
```

#### `test-endpoint.sh`
```bash
ENDPOINT_URL="https://your-actual-endpoint.runpod.net"
API_KEY="your-actual-api-key"
```

### 5. Первый деплой

После настройки secrets и конфигурации:

1. **Автоматический деплой**: Просто отправьте изменения в main ветку
```bash
git add .
git commit -m "Update configuration"
git push
```

2. **Ручной деплой**: Перейдите в Actions → Build and Deploy ComfyUI → Run workflow

### 6. Создание RunPod Endpoint

После успешной сборки образа:

1. Войдите в [RunPod Console](https://www.runpod.io/console)
2. Перейдите в Serverless
3. Создайте новый endpoint
4. Используйте шаблон из `runpod-template.json`
5. Замените `YOUR_USERNAME` на ваше GitHub имя пользователя
6. Замените `YOUR_RUNPOD_STORAGE_ID` на ID вашего storage

## 🔧 GitHub Actions Workflows

### Автоматическая сборка (`build-and-deploy.yml`)
- Запускается при push в main/master
- Собирает Docker образ
- Отправляет в GitHub Container Registry
- Автоматически деплоит в RunPod (если настроен)

### Тестирование (`test.yml`)
- Ручной запуск для тестирования endpoint
- Позволяет указать URL endpoint и workflow
- Проверяет работоспособность API

## 📊 Мониторинг

### GitHub Actions
- Перейдите в Actions для просмотра статуса сборки
- Логи показывают детали процесса

### RunPod Console
- Мониторинг endpoint в реальном времени
- Логи выполнения
- Статистика использования

## 🛠️ Устранение неполадок

### Ошибки сборки
1. Проверьте логи в GitHub Actions
2. Убедитесь, что Dockerfile корректен
3. Проверьте права доступа к GitHub Container Registry

### Ошибки деплоя
1. Проверьте `RUNPOD_API_KEY` в secrets
2. Убедитесь, что RunPod Storage доступен
3. Проверьте конфигурацию в `runpod-template.json`

### Ошибки тестирования
1. Убедитесь, что endpoint создан и работает
2. Проверьте API ключ
3. Проверьте структуру workflow JSON

## 🔄 Обновления

### Автоматические обновления
Dependabot будет автоматически создавать PR для обновления:
- Docker базовых образов
- GitHub Actions
- Python зависимостей

### Ручные обновления
```bash
# Обновите код
git pull origin main

# Отправьте изменения
git add .
git commit -m "Update dependencies"
git push
```

## 📈 Оптимизация

### Кэширование
- GitHub Actions использует кэширование для ускорения сборки
- Docker слои кэшируются между сборками

### Безопасность
- API ключи хранятся в GitHub Secrets
- Образы подписываются и сканируются
- Автоматические обновления безопасности

## 🎯 Следующие шаги

1. **Настройте n8n интеграцию** (см. `n8n-integration.md`)
2. **Добавьте мониторинг** (логи, метрики)
3. **Настройте алерты** при ошибках
4. **Оптимизируйте производительность** (кэширование, размер образов)
