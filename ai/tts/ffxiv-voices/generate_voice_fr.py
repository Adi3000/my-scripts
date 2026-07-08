import torchaudio as ta
import torch
import os
import subprocess
import sys
import csv
import soundfile as sf
from pathlib import Path
from chatterbox.tts import ChatterboxTTS
from huggingface_hub import hf_hub_download
from safetensors.torch import load_file



MODEL_REPO = "Thomcles/Chatterbox-TTS-French"
CHECKPOINT_FILENAME = "t3_cfg.safetensors"
OUTPUT_DIR=os.environ.get('GENERATED_VOICES_DIR', "/data/voices")
PGHOST=os.environ.get('GENERATED_VOICES_DIR', "/data/voices")

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


if __name__ == "__main__":

    AUDIO_PROMPT_PATH = sys.argv[1]
    CSV_LINES = sys.argv[2]
    model = load_tts_model(MODEL_REPO, CHECKPOINT_FILENAME, "cuda")

    print(f"Reading CSV {CSV_LINES} to process through audio prompt {AUDIO_PROMPT_PATH}")
    with open(CSV_LINES, newline='') as csvfile:
        lines = csv.reader(csvfile, delimiter='|')
        nb_lines=int(subprocess.check_output(['wc', '-l', CSV_LINES]).split()[0])
        current_line=1
        for line in lines:
            wav_output=f"{OUTPUT_DIR}/{line[0]}.wav"
            text = line[1].replace("_NAME_", "Coton")
            print(f"\n========> line {current_line}/{nb_lines} : {line[0]} ({CSV_LINES})\n")
            wav =  synthesize_speech(model, text, audio_prompt_path=AUDIO_PROMPT_PATH)
            save_audio(wav, wav_output, model.sr)
            subprocess.call(["ffmpeg", "-i", wav_output, "-acodec","libopus", "-f", "ogg", "-y", f"{OUTPUT_DIR}/{line[0]}.ogg"])
            subprocess.call(["rm", "-f", wav_output])
            subprocess.call(["psql", "-U", "postgres", "-c", f"update ffxivv_data fd set last_generation_date = current_timestamp where fd.id = '{line[0]}';"])

            current_line=current_line+1

    subprocess.call(["mv", CSV_LINES, f"{CSV_LINES}.done"])
