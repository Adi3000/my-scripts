#!/bin/bash

while read  voice_line; do
    file=$(echo "$voice_line" | cut -d, -f1 | sed -E 's/text_voiceman_([^_]+)_([^_]+)_.*/vo_voiceman_\1_\2_m_fr.scd/g')
    voice=$(echo "$voice_line" | cut -d, -f2 )
    find /mnt/stockage/Jeux/FFXIV-extract/voices/cut -name $file -exec /mnt/stockage/Jeux/FFXIV-extract/vgmstream-cli -o "/mnt/stockage/Jeux/FFXIV-extract/voices/$voice.wav" "{}" \; 
done < "/mnt/stockage/Jeux/FFXIV-extract/voice_sample.csv"



find /mnt/stockage/Jeux/FFXIV-extract/voices -maxdepth 1 -type f -name "*.wav" -print0 |
while IFS= read -r -d '' file; do
    basename=$(basename "$file")
    voice=$(echo "${basename%.wav}" | sed -r "s/'/''/g")
    echo "voice $voice"
    psql -U postgres -d ffxivv -h adi3000.com -p 5432 -c "\copy (SELECT id, sentence_fr from ffxivv_data where voice_id='$voice' and sentence_fr is not null) to '/mnt/stockage/Jeux/FFXIV-extract/voices/${voice}.csv' WITH CSV DELIMITER '|'"
done


find /mnt/stockage/Jeux/FFXIV-extract/voices -maxdepth 1 -type f -name "*.csv" -print0 |
while IFS= read -r -d '' voice; do
    wav_file="${voice%.csv}.wav"
    echo "####### PROCESSING VOICE $voice ($wav_file|$csv_file)########"
    /mnt/stockage/Jeux/FFXIV-extract/tts/faster-qwen3-tts/.venv/bin/python /mnt/stockage/Jeux/FFXIV-extract/tts/faster-qwen3-tts/test_chatterbot.py "$wav_file" "$voice"
done





find . -maxdepth 1 -type f -print0 |
while IFS= read -r -d '' file; do
    echo "$file"
done