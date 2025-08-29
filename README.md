# ComfyUI на RunPod Serverless

Развертывание ComfyUI на RunPod Serverless с GPU для интеграции с n8n через HTTP API с полной GitHub интеграцией.

## 🚀 Быстрый старт

1. **Создайте репозиторий на GitHub**
2. **Настройте GitHub Secrets**
3. **Настройте RunPod Storage**
4. **Запустите первый деплой**

Подробная инструкция: [GITHUB_SETUP.md](GITHUB_SETUP.md)

## Структура проекта

```
comfyui-runpod/
├── .github/
│   ├── workflows/
│   │   ├── build-and-deploy.yml    # Автоматическая сборка и деплой
│   │   └── test.yml                # Тестирование endpoint
│   └── dependabot.yml              # Автоматические обновления
├── Dockerfile                      # Образ Docker с ComfyUI
├── handler.py                      # RunPod serverless handler
├── startup.sh                      # Скрипт запуска ComfyUI
├── requirements.txt                # Python зависимости
├── runpod-template.json            # Шаблон RunPod
├── n8n-integration.md              # Инструкция по интеграции с n8n
├── n8n-workflow-example.json       # Пример workflow для n8n
├── build-and-deploy.sh             # Локальный скрипт сборки
├── test-endpoint.sh                # Локальный скрипт тестирования
├── GITHUB_SETUP.md                 # Настройка GitHub интеграции
└── README.md                       # Эта инструкция
```

## 🔄 GitHub Actions Workflows

### Автоматическая сборка и деплой
- **Триггер**: Push в main/master ветку
- **Действия**: 
  - Сборка Docker образа
  - Отправка в GitHub Container Registry
  - Автоматический деплой в RunPod

### Тестирование endpoint
- **Триггер**: Ручной запуск
- **Действия**: Тестирование API endpoint

## Шаги развертывания

### 1. Подготовка RunPod Storage

Убедитесь, что ваш RunPod Storage содержит следующую структуру:
```
/runpod-volume/
├── models/
│   ├── checkpoints/        # Модели .safetensors
│   ├── loras/             # LoRA модели
│   ├── vae/               # VAE модели
│   └── controlnet/        # ControlNet модели
└── custom_nodes/          # Кастомные ноды
```

### 2. Настройка GitHub Secrets

В вашем GitHub репозитории → Settings → Secrets and variables → Actions добавьте:

- `RUNPOD_API_KEY` - API ключ RunPod
- `RUNPOD_ENDPOINT` - URL вашего endpoint (опционально)

### 3. Автоматический деплой

После настройки secrets просто отправьте изменения в main ветку:

```bash
git add .
git commit -m "Initial setup"
git push origin main
```

GitHub Actions автоматически:
1. Соберет Docker образ
2. Отправит в GitHub Container Registry
3. Развернет в RunPod

### 4. Настройка RunPod Serverless

1. Войдите в RunPod Console
2. Перейдите в раздел "Serverless"
3. Создайте новый endpoint
4. Используйте шаблон из `runpod-template.json`
5. Замените `YOUR_USERNAME` на ваше GitHub имя пользователя
6. Замените `YOUR_RUNPOD_STORAGE_ID` на ID вашего storage

### 5. Тестирование endpoint

#### Через GitHub Actions
1. Перейдите в Actions → Test ComfyUI Endpoint
2. Нажмите "Run workflow"
3. Укажите URL вашего endpoint
4. Запустите тест

#### Локально
```bash
# Отредактируйте test-endpoint.sh с вашими данными
nano test-endpoint.sh

# Запустите тест
./test-endpoint.sh
```

## Интеграция с n8n

Подробная инструкция по настройке n8n находится в файле `n8n-integration.md`.

Пример workflow для n8n: `n8n-workflow-example.json`

## Мониторинг и логи

### GitHub Actions
- Перейдите в Actions для просмотра статуса сборки
- Логи показывают детали процесса

### RunPod Console
- Мониторинг endpoint в реальном времени
- Логи выполнения
- Статистика использования

## Устранение неполадок

### ComfyUI не запускается
- Проверьте логи в RunPod Console
- Убедитесь, что GPU доступен
- Проверьте подключение RunPod Storage

### Модели не загружаются
- Проверьте структуру папок в RunPod Storage
- Убедитесь, что файлы моделей корректны
- Проверьте права доступа к файлам

### API не отвечает
- Проверьте, что ComfyUI запустился (логи)
- Убедитесь, что порт 8188 открыт
- Проверьте настройки firewall

### Ошибки GitHub Actions
- Проверьте GitHub Secrets
- Убедитесь, что права доступа настроены
- Проверьте логи в Actions

## Оптимизация

- Используйте SSD storage для быстрой загрузки моделей
- Настройте кэширование моделей в памяти
- Оптимизируйте размер workflow для быстрого выполнения
- GitHub Actions использует кэширование для ускорения сборки

## 🔄 Обновления

### Автоматические обновления
Dependabot будет автоматически создавать PR для обновления:
- Docker базовых образов
- GitHub Actions
- Python зависимостей

### Ручные обновления
```bash
git pull origin main
git add .
git commit -m "Update dependencies"
git push
```

## 📈 Преимущества GitHub интеграции

- **Автоматизация**: Автоматическая сборка и деплой при изменениях
- **Безопасность**: API ключи хранятся в GitHub Secrets
- **Мониторинг**: Полная история сборок и деплоев
- **Тестирование**: Встроенное тестирование endpoint
- **Обновления**: Автоматические обновления зависимостей
- **Версионирование**: Полная история изменений
- **Коллаборация**: Возможность совместной работы над проектом
