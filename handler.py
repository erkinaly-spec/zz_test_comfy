import os, time, json, base64, subprocess, requests
import runpod

COMFY_DIR = "/app/ComfyUI"
COMFY_PORT = int(os.getenv("COMFY_PORT", "8188"))
COMFY_URL = f"http://127.0.0.1:{COMFY_PORT}"

_server_proc = None
_started = False

def _start_comfy_once():
    global _server_proc, _started
    if _started:
        return
    _server_proc = subprocess.Popen(
        ["python3", "main.py", "--port", str(COMFY_PORT), "--listen", "127.0.0.1", "--headless"],
        cwd=COMFY_DIR
    )
    # ждём, пока сервер ComfyUI поднимется
    for _ in range(180):
        try:
            r = requests.get(COMFY_URL, timeout=2)
            if r.status_code in (200, 404):  # корень может отдавать 404 — это ок
                _started = True
                break
        except Exception:
            time.sleep(1)
    if not _started:
        raise RuntimeError("ComfyUI не запустился вовремя")

def _submit_workflow(workflow_json):
    r = requests.post(f"{COMFY_URL}/prompt", json=workflow_json, timeout=30)
    r.raise_for_status()
    prompt_id = r.json().get("prompt_id")
    # ждём завершения
    for _ in range(3600):
        h = requests.get(f"{COMFY_URL}/history/{prompt_id}", timeout=30)
        if h.status_code == 200:
            data = h.json()
            if prompt_id in data and data[prompt_id].get("status", {}).get("status") == "completed":
                return data[prompt_id]
        time.sleep(1)
    raise RuntimeError("ComfyUI job timeout")

def _images_from_history(history_obj):
    images = []
    outputs = history_obj.get("outputs", {})
    for node in outputs.values():
        for img in node.get("images", []):
            path = os.path.join(COMFY_DIR, "output", img["filename"])
            if os.path.isfile(path):
                with open(path, "rb") as f:
                    images.append("data:image/png;base64," + base64.b64encode(f.read()).decode())
    return images

def handler(job):
    """
    input варианты:
    {
      "ping": true               # быстрый тест без моделей
    }
    или
    {
      "workflow": {...}          # JSON-граф ComfyUI
    }
    или
    {
      "workflow_url": "https://..."  # ссылка на JSON-граф
    }
    """
    payload = job.get("input", {})

    if payload.get("ping"):
        return {"ok": True, "message": "pong"}

    _start_comfy_once()

    if "workflow" in payload:
        workflow = payload["workflow"]
    elif "workflow_url" in payload:
        workflow = requests.get(payload["workflow_url"], timeout=60).json()
    else:
        raise ValueError("Нужно передать 'workflow' или 'workflow_url'")

    history = _submit_workflow(workflow)
    images = _images_from_history(history)

    return {
        "status": "completed",
        "images": images,
        "meta": {k: v.get("status", {}) for k, v in history.items()}
    }

runpod.serverless.start({"handler": handler})
