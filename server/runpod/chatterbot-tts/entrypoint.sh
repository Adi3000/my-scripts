
#!/bin/bash
mkdir -p /data/voices /data/voices_overrides /root/.cache /workspace/cache/huggingface
ln -s /runpod-volume/huggingface-cache/hub /workspace/cache/huggingface/hub  || true
ln -s /workspace/cache/huggingface /root/.cache/huggingface  || true
wget https://raw.githubusercontent.com/Adi3000/my-scripts/refs/heads/main/server/runpod/chatterbot-tts/handler.py -O /workspace/handler.py

python /workspace/handler.py
