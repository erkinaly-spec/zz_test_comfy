import runpod
import requests
import json
import time
import os
from typing import Dict, Any

# Конфигурация ComfyUI API
COMFYUI_URL = "http://localhost:8188"
API_BASE = f"{COMFYUI_URL}/api"

def wait_for_comfyui():
    """Ожидание запуска ComfyUI"""
    max_attempts = 30
    for attempt in range(max_attempts):
        try:
            response = requests.get(f"{COMFYUI_URL}/system_stats", timeout=5)
            if response.status_code == 200:
                print("ComfyUI готов к работе")
                return True
        except:
            pass
        time.sleep(2)
    return False

def queue_workflow(workflow_data: Dict[str, Any]) -> str:
    """Отправка workflow в очередь ComfyUI"""
    try:
        response = requests.post(f"{API_BASE}/queue", json=workflow_data, timeout=30)
        response.raise_for_status()
        result = response.json()
        return result.get("prompt_id")
    except Exception as e:
        raise Exception(f"Ошибка при отправке workflow: {str(e)}")

def get_workflow_status(prompt_id: str) -> Dict[str, Any]:
    """Получение статуса выполнения workflow"""
    try:
        response = requests.get(f"{API_BASE}/history/{prompt_id}", timeout=10)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        raise Exception(f"Ошибка при получении статуса: {str(e)}")

def get_workflow_result(prompt_id: str) -> Dict[str, Any]:
    """Получение результатов выполнения workflow"""
    try:
        response = requests.get(f"{API_BASE}/history/{prompt_id}", timeout=10)
        response.raise_for_status()
        history = response.json()
        
        if prompt_id in history:
            result = history[prompt_id]
            if "outputs" in result:
                return {
                    "status": "completed",
                    "outputs": result["outputs"],
                    "prompt_id": prompt_id
                }
        
        return {"status": "processing", "prompt_id": prompt_id}
    except Exception as e:
        raise Exception(f"Ошибка при получении результатов: {str(e)}")

def handler(job):
    """Основной обработчик RunPod serverless"""
    try:
        # Получение данных из запроса
        job_input = job["input"]
        
        # Проверка наличия workflow
        if "workflow" not in job_input:
            return {"error": "Отсутствует workflow в запросе"}
        
        workflow = job_input["workflow"]
        timeout = job_input.get("timeout", 300)  # 5 минут по умолчанию
        
        # Ожидание запуска ComfyUI
        if not wait_for_comfyui():
            return {"error": "ComfyUI не запустился в течение ожидаемого времени"}
        
        # Отправка workflow в очередь
        prompt_id = queue_workflow(workflow)
        if not prompt_id:
            return {"error": "Не удалось получить prompt_id"}
        
        # Ожидание завершения выполнения
        start_time = time.time()
        while time.time() - start_time < timeout:
            result = get_workflow_result(prompt_id)
            
            if result["status"] == "completed":
                return {
                    "success": True,
                    "prompt_id": prompt_id,
                    "outputs": result["outputs"]
                }
            
            time.sleep(2)
        
        # Таймаут
        return {
            "error": f"Таймаут выполнения workflow (>{timeout} секунд)",
            "prompt_id": prompt_id,
            "status": "timeout"
        }
        
    except Exception as e:
        return {"error": f"Ошибка обработки: {str(e)}"}

# Запуск RunPod handler
if __name__ == "__main__":
    runpod.serverless.start({"handler": handler})
