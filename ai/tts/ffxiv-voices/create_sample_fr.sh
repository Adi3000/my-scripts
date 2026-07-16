#!/bin/bash
mkdir -p /data/voices_sample /data/voices_fr /root/.cache /workspace/cache/huggingface
ln -s /workspace/cache/huggingface /root/.cache/huggingface
wget https://raw.githubusercontent.com/Adi3000/my-scripts/refs/heads/main/ai/tts/ffxiv-voices/generate_voice_sample_fr.py -O /workspace/generate_voice_sample_fr.py
wget https://raw.githubusercontent.com/Adi3000/my-scripts/refs/heads/main/ai/tts/ffxiv-voices/en_voices_to_fr.csv -O /workspace/en_voices_to_fr.csv
wget https://nextcloud.adi3000.com/public.php/dav/files/$NEXTCLOUD_SHARE_TOKEN/voices_sample?accept=zip -O /data/voices_sample.zip
unzip -o  /data/voices_sample.zip -d  /data 

python /workspace/generate_voice_sample_fr.py "/workspace/en_voices_to_fr.csv" 
