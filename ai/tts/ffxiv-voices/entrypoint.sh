#!/bin/bash
wget https://raw.githubusercontent.com/Adi3000/my-scripts/refs/heads/main/ai/tts/ffxiv-voices/generate_voice_fr.py -O /workspace/generate_voice_fr.py
wget https://nextcloud.adi3000.com/public.php/dav/files/$NEXTCLOUD_SHARE_TOKEN/voices?accept=zip -O /data/voices.zip
unzip -o  /data/voices.zip -d  /data 

find /data/voices -maxdepth 1 -type f -name "*.csv" -print0 |
while IFS= read -r -d '' voice; do
    wav_file="${voice%.csv}.wav"
    echo "####### PROCESSING VOICE $voice ($wav_file|$csv_file)########"
    python /workspace/generate_voice_fr.py "$wav_file" "$voice"
done

