import requests
import logging  
import os
from audit import telegram

LLAMA_URL = os.getenv("LLAMA_URL", "http://localhost:8080")
LLAMA_FAILBACK_URL = os.getenv("LLAMA_FAILBACK_URL", "http://localhost:8080")
LLAMA_MAX_WORDS= int(os.getenv("LLAMA_MAX_WORDS","1000"))


logger = logging.getLogger(__name__)

stop_list = [
        "</s>",
        "<|end|>",
        "<|eot_id|>",
        "<|end_of_text|>",
        "<|im_end|>",
        "<|EOT|>",
        "<|END_OF_TURN_TOKEN|>",
        "<|end_of_turn|>",
        "<|endoftext|>",
        "assistant",
        "user"
    ]

json_template = {
    "stop": [
        "</s>",
        "<|end|>",
        "<|eot_id|>",
        "<|end_of_text|>",
        "<|im_end|>",
        "<|EOT|>",
        "<|END_OF_TURN_TOKEN|>",
        "<|end_of_turn|>",
        "<|endoftext|>",
        "cerbinou",
        "user"
    ],
    "repeat_penalty": 1.7,
    "penalize_nl": True,
    "top_p": 0.6,
    "temperature": 0.9,
    "cache_prompt": True,
}

prompt_context =  "Bonjour, comment ça va ?<|eot_id|><|start_header_id|>cerbinou<|end_header_id|>\n\nJe vais bien merci ! Et toi ? Qu'est-ce que tu veux savoir ou faire aujourd'hui ?<|eot_id|><|start_header_id|>user<|end_header_id|>\n\n"


def get_prompt_response(prompt: str):
    global prompt_context
    add_prompt_to_context(prompt)
    try:
        response= requests.post(f"{LLAMA_URL}/completion", json= {"prompt": purge_context(prompt_context)}, timeout=(2,30))
    except requests.exceptions.Timeout:
        response = requests.post(url=f"{LLAMA_FAILBACK_URL}/completion", json= {"prompt": purge_context(prompt_context)})
        logging.info("timeout from [%s] response from : %s", f"{LLAMA_URL}", LLAMA_FAILBACK_URL)
    except requests.exceptions.ConnectionError:
        response = requests.post(url=f"{LLAMA_FAILBACK_URL}/completion", json= {"prompt": purge_context(prompt_context)})
        logging.info("connection refuse to[%s] response from : %s",LLAMA_URL, LLAMA_FAILBACK_URL)
    logger.info("Response output %s", response.json())
    json_response = response.json().get("content")
    add_answer_to_context(json_response)
    telegram.send_message(text=prompt, quote=True)
    return json_response

def add_prompt_to_context(prompt: str):
    global prompt_context
    prompt_context += f"{prompt}<|eot_id|><|start_header_id|>cerbinou<|end_header_id|>\n\n"

def add_answer_to_context(answer: str):
    global prompt_context
    prompt_context += f"{answer}<|eot_id|><|start_header_id|>user<|end_header_id|>\n\n"
    
def check_nb_token(context: str):
    sanitized_text = context.replace("<|eot_id|><|start_header_id|>cerbinou<|end_header_id|>", "").replace("<|eot_id|><|start_header_id|>user<|end_header_id|>", "")
    return len(sanitized_text.split()) <= LLAMA_MAX_WORDS

def purge_context(context: str):
    if check_nb_token(context):
        return context
    else:
        context_parts = context("<|eot_id|><|start_header_id|>user<|end_header_id|>\n\n", 1)
        if(len(context_parts) > 1):
            return purge_context(context_parts[1])
        else:
            return context
