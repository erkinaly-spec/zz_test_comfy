#!/bin/bash

# Скрипт для сборки и развертывания ComfyUI на RunPod

set -e

# Конфигурация
REGISTRY="your-registry"  # Замените на ваш registry
IMAGE_NAME="comfyui-runpod"
TAG="latest"
FULL_IMAGE_NAME="$REGISTRY/$IMAGE_NAME:$TAG"

echo "🚀 Начинаем сборку и развертывание ComfyUI на RunPod..."

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Установите Docker и попробуйте снова."
    exit 1
fi

# Сборка Docker образа
echo "📦 Сборка Docker образа: $FULL_IMAGE_NAME"
docker build -t $FULL_IMAGE_NAME .

if [ $? -eq 0 ]; then
    echo "✅ Образ успешно собран"
else
    echo "❌ Ошибка при сборке образа"
    exit 1
fi

# Отправка в registry
echo "📤 Отправка образа в registry..."
docker push $FULL_IMAGE_NAME

if [ $? -eq 0 ]; then
    echo "✅ Образ успешно отправлен в registry"
else
    echo "❌ Ошибка при отправке образа"
    exit 1
fi

echo ""
echo "🎉 Сборка и отправка завершены!"
echo ""
echo "📋 Следующие шаги:"
echo "1. Войдите в RunPod Console"
echo "2. Перейдите в раздел 'Serverless'"
echo "3. Создайте новый endpoint"
echo "4. Используйте образ: $FULL_IMAGE_NAME"
echo "5. Настройте RunPod Storage в шаблоне"
echo "6. Протестируйте endpoint"
echo ""
echo "📖 Подробные инструкции в README.md"
