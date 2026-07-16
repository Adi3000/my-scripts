#!/bin/bash
mkdir -p /data/voices /data/voices_overrides /root/.cache /workspace/cache/huggingface
ln -s /workspace/cache/huggingface /root/.cache/huggingface
wget https://raw.githubusercontent.com/Adi3000/my-scripts/refs/heads/main/ai/tts/ffxiv-voices/generate_voice_fr.py -O /workspace/generate_voice_fr.py
wget https://nextcloud.adi3000.com/public.php/dav/files/$NEXTCLOUD_SHARE_TOKEN/voices?accept=zip -O /data/voices.zip
unzip -o  /data/voices.zip -d  /data 

max_thread_running=${NB_THREADS:-1}

find /data/voices -maxdepth 1 -type f -name "*.wav" -print0 |
while IFS= read -r -d '' wav_file; do
    (
        voice="$(basename "${wav_file%.wav}")"
        echo "####### PROCESSING VOICE $voice ($wav_file)########"
        python /workspace/generate_voice_fr.py "$wav_file" "$voice"
    ) &
    ((running++))

    if (( running >= NB_THREADS )); then
        wait -n
        ((running--))
    fi
done
wait
