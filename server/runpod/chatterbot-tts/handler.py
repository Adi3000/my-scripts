import torchaudio as ta
import torch
import os
import sys
import io
import base64
from chatterbox.tts import ChatterboxTTS
from huggingface_hub import hf_hub_download
from safetensors.torch import load_file
import soundfile as sf
import runpod

MODEL_REPO = os.environ.get("MODEL_REPO","Thomcles/Chatterbox-TTS-French")
CHECKPOINT_FILENAME = "t3_cfg.safetensors"
VOICES_DIR = os.environ.get('VOICES_DIR', "/data/voices")
YOUR_NAME = os.environ.get('YOUR_NAME',"Notre cher ami")
CHATTERBOX_EXGERATION = float(os.environ.get('CHATTERBOX_EXGERATION',"0.8"))
CHATTERBOX_TEMPERATURE = float(os.environ.get('CHATTERBOX_TEMPERATURE',"0.6"))
CHATTERBOX_CFG_WEIGHT = float(os.environ.get('CHATTERBOX_CFG_WEIGHT',"0.5"))

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
            exaggeration=CHATTERBOX_EXGERATION,
            temperature=CHATTERBOX_TEMPERATURE,
            cfg_weight=CHATTERBOX_CFG_WEIGHT,
            **kwargs
        )

def handler(job):
    input = job["input"]  # Access the input from the request
    prompt = input.get('text')  
    name_value = input.get('name_value', YOUR_NAME)  
    text = prompt.replace("_NAME_", name_value)
    voice_id = input.get('voice_id')
    waveform = synthesize_speech(model, text, audio_prompt_path=f"{VOICES_DIR}/{voice_id}.wav")
    wav = io.BytesIO()
    sf.write(wav, waveform.squeeze().cpu().numpy(), sample_rate)
    return { "wav": base64.b64encode(wav.getvalue()).decode("utf-8"), "sample_rate": model.sr }

if __name__ == "__main__":
    model = load_tts_model(MODEL_REPO, CHECKPOINT_FILENAME, "cuda")
    runpod.serverless.start({'handler': handler })
