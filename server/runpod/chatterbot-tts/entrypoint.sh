
#!/bin/bash
pip3 install runpod
mkdir -p /data/voices /data/voices_overrides /root/.cache /workspace/cache/huggingface
ln -s /workspace/cache/huggingface /root/.cache/huggingface  || true
wget https://raw.githubusercontent.com/Adi3000/my-scripts/refs/heads/main/server/runpod/chatterbot-tts/handler.py -O /workspace/handler.py
wget https://nextcloud.adi3000.com/public.php/dav/files/$NEXTCLOUD_SHARE_TOKEN/voices?accept=zip -O /data/voices.zip
unzip -o  /data/voices.zip -d  /data

python /workspace/generate_voice_fr.py