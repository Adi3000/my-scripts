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
OUTPUT_FR_DIR=os.environ.get('OUTPUT_FR_DIR', "/data/voices_fr")
INPUT_EN_DIR=os.environ.get('INPUT_EN_DIR', "/data/voices_sample")
NEXTCLOUD_URL = os.environ.get('NEXTCLOUD_URL', "https://cloud.example.com" )
NEXTCLOUD_SHARE_TOKEN = os.environ.get('NEXTCLOUD_SHARE_TOKEN')
NEXTCLOUD_SHARE_PASSWORD = os.environ.get('NEXTCLOUD_SHARE_PASSWORD', '')
FFXIVV_NOTIFIER_URL= os.environ.get('FFXIVV_NOTIFIER_URL', "https://ffxivv.example.com" )

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
            exaggeration=1.0,
            temperature=0.6,
            cfg_weight=0.1,
            **kwargs
        )

def save_audio(waveform: torch.Tensor, path: str, sample_rate: int):
    sf.write(path, waveform.squeeze().cpu().numpy(), sample_rate)

def upload_audio(ogg_file: str, file_name: str):
    
    remote_path = (
        f"{NEXTCLOUD_URL}/public.php/dav/files/{NEXTCLOUD_SHARE_TOKEN}"
        f"/voices_fr/{file_name}"
    )
    print(f"\n========> Will upload {ogg_file} to : {remote_path}\n")

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

    CSV_LINES = sys.argv[1]
    lines = list()
    with open(CSV_LINES, newline="", encoding="utf-8") as csvfile:
        model = load_tts_model(MODEL_REPO, CHECKPOINT_FILENAME, "cuda")
        lines = list(csv.reader(csvfile, delimiter=','))
    
    nb_lines=len(lines)
    print(f"Reading CSV {CSV_LINES}:{nb_lines} lines to process")
    current_line=1
    for line in lines:
        voice_en = f"{INPUT_EN_DIR}/{line[0]}.wav"
        wav_output=f"{OUTPUT_FR_DIR}/{line[1]}.wav"
        text = line[2].replace("_NAME_", "Coton")
        print(f"\n========> line {current_line}/{nb_lines+1} : {line[0]} ({line[1]})  \n")
        wav =  synthesize_speech(model, text, audio_prompt_path=voice_en)
        save_audio(wav, wav_output, model.sr)
        upload_ok = upload_audio(wav_output, f"{line[1]}.wav")
        current_line=current_line+1

