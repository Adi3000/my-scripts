import torchaudio as ta
import torch
import os
import subprocess
import sys
import io
from urllib.parse import urlparse
from pathlib import PurePosixPath
import csv
import soundfile as sf
from pathlib import Path
from chatterbox.tts import ChatterboxTTS
from huggingface_hub import hf_hub_download
from safetensors.torch import load_file
from datetime import datetime
import requests




MODEL_REPO = "Thomcles/Chatterbox-TTS-French"
CHECKPOINT_FILENAME = "t3_cfg.safetensors"
OUTPUT_DIR=os.environ.get('GENERATED_VOICES_DIR', "/data/voices_overrides")
NEXTCLOUD_URL = os.environ.get('NEXTCLOUD_URL', "https://cloud.example.com" )
NEXTCLOUD_SHARE_TOKEN = os.environ.get('NEXTCLOUD_SHARE_TOKEN')
NEXTCLOUD_SHARE_PASSWORD = os.environ.get('NEXTCLOUD_SHARE_PASSWORD', '')
FFXIVV_NOTIFIER_URL= os.environ.get('FFXIVV_NOTIFIER_URL', "https://ffxivv.example.com" )
BATCH_START_DATE= os.environ.get('BATCH_START_DATE', datetime(1970, 1, 1).isoformat() )

def get_device() -> str:
    return "cuda" if torch.cuda.is_available() else "cpu"

def download_checkpoint(repo: str, filename: str) -> str:
    return hf_hub_download(repo_id=repo, filename=filename)

def load_tts_model(repo: str, checkpoint_file: str, device: str) -> ChatterboxTTS:
    model = ChatterboxTTS.from_pretrained(device=device)
    checkpoint_path = download_checkpoint(repo, checkpoint_file)
    t3_state = load_file(checkpoint_path, device="cuda")
    model.t3.load_state_dict(t3_state)
    return model

def synthesize_speech(model: ChatterboxTTS, text: str, audio_prompt_path:str, **kwargs) -> torch.Tensor:
    with torch.inference_mode():
        return model.generate(
            text=text, 
            audio_prompt_path=audio_prompt_path,
            exaggeration=0.5,
            temperature=0.6,
            cfg_weight=0.3,
            **kwargs
        )

def save_audio(waveform: torch.Tensor, path: str, sample_rate: int):
    sf.write(path, waveform.squeeze().cpu().numpy(), sample_rate)

def upload_audio(ogg_file: str, file_name: str):
    
    remote_path = (
        f"{NEXTCLOUD_URL}/public.php/dav/files/{NEXTCLOUD_SHARE_TOKEN}"
        f"/voices_overrides/{file_name}"
    )
    print(f"\n========> Will upload {ogg_file} to : {remote_path})\n")

    with open(ogg_file, "rb") as f:
        response = requests.put(
            remote_path,
            data=f,
            headers={
                "Content-Type": "audio/ogg",
            },
        )
        print(f"Uploaded : {response}")
        return response.ok
    return False

if __name__ == "__main__":

    AUDIO_PROMPT_PATH = sys.argv[1]
    voice_id = sys.argv[2]

    last_generation_date = requests.get(f"{FFXIVV_NOTIFIER_URL}/voicelines/lastest-generation").text
    csv_reponse = requests.get(
        f"{FFXIVV_NOTIFIER_URL}/voicelines/{voice_id}?last_update_date={BATCH_START_DATE}&last_generation_date={last_generation_date}"
    )
    csv_reponse.raise_for_status()

    csvfile = io.StringIO(csv_reponse.text)
    model = load_tts_model(MODEL_REPO, CHECKPOINT_FILENAME, "cuda")
    print(f"Reading CSV {voice_id} to process through audio prompt {AUDIO_PROMPT_PATH}")
    lines = csv.reader(csvfile, delimiter='|')
    nb_lines=len(lines)
    current_line=1
    for line in lines:
        wav_output=f"{OUTPUT_DIR}/{line[0]}.wav"
        text = line[1].replace("_NAME_", "Coton")
        print(f"\n========> line {current_line}/{nb_lines+1} : {line[0]} ({voice_id}) from U {BATCH_START_DATE} G {last_generation_date} \n")
        wav =  synthesize_speech(model, text, audio_prompt_path=AUDIO_PROMPT_PATH)
        save_audio(wav, wav_output, model.sr)
        subprocess.call(["ffmpeg", "-loglevel", "warning" ,"-nostdin","-hide_banner", "-i", wav_output, "-acodec","libopus", "-f", "ogg", "-y", f"{OUTPUT_DIR}/{line[0]}.ogg"])
        upload_ok = upload_audio(f"{OUTPUT_DIR}/{line[0]}.ogg", f"{line[0]}.ogg")
        subprocess.call(["rm", "-f", wav_output])
        if upload_ok:
            notif_ok = requests.put(f"{FFXIVV_NOTIFIER_URL}/voicelines/line/{line[0]}/last-generation-date")
            print(f"notified to {FFXIVV_NOTIFIER_URL}/voicelines/line/{line[0]}/last-generation-date : {notif_ok}")
        else: 
            print(f"[ERROR] Didn't manage to upload {line[0]}, still skipping")
        current_line=current_line+1

